//
//  EventViewController.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/7/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import EventKit
import SwiftFoundation
import CoreSummit

protocol EventViewController: class, MessageEnabledViewController {
    
    var eventRequestInProgress: Bool { get set }
    
    var eventStore: EKEventStore { get }
}

extension EventViewController {
    
    func canAddFeedback(for event: EventDetail) -> Bool {
        
        // Can give feedback after event started
        return Store.shared.isLoggedIn
            && event.allowFeedback
            && event.start < Date()
    }
    
    func canAddToCalendar() -> Bool {
        
        let status = EKEventStore.authorizationStatusForEntityType(.Event)
        
        switch status {
        case .NotDetermined, .Authorized: return true
        case .Restricted, .Denied: return false
        }
    }
    
    func contextMenu(for event: EventDetail) -> ContextMenu {
        
        let scheduled = Store.shared.isEventScheduledByLoggedMember(event: event.identifier)
        
        let message = "Check out this #OpenStack session I’m attending at the #OpenStackSummit!"
        
        let url = event.webpageURL
        
        var actions: [ContextMenu.Action] = []
        
        if canAddFeedback(for: event) {
            
            let rate = ContextMenu.Action(activityType: "Event.Rate", image: { R.image.contextMenuRate()! }, title: "Rate", handler: .modal({ [weak self] (didComplete) -> UIViewController in
                
                return self!.feedbackController(for: event) { _ in didComplete(true) }
                }))
            
            actions.append(rate)
        }
        
        let isAttendee = Store.shared.isLoggedInAndConfirmedAttendee
        
        if isAttendee && eventRequestInProgress == false {
            
            let newValue = scheduled == false
            
            let title = newValue ? "Schedule" : "Unschedule"
            
            let image = newValue ? R.image.contextMenuScheduleAdd()! : R.image.contextMenuScheduleRemove()!
            
            let scheduleEvent = ContextMenu.Action(activityType: "Event.Schedule", image: { image }, title: title, handler: .background({ [weak self] (didComplete) in
                
                guard let controller = self else { return }
                
                controller.toggleScheduledStatus(for: event)
                
                didComplete(true)
                }))
            
            actions.append(scheduleEvent)
        }
        
        let isFavorite = Store.shared.authenticatedMember?.isFavorite(event: event.identifier) ?? false
        
        if Store.shared.isLoggedIn && eventRequestInProgress == false {
            
            let newValue = isFavorite == false
            
            let title = newValue ? "Watch Later" : "Don’t Watch Later"
            
            let favoriteEvent = ContextMenu.Action(activityType: "Event.Favorite", image: { R.image.contextMenuWatchListAdd()! }, title: title, handler: .background({ [weak self] (didComplete) in
                
                guard let controller = self else { return }
                
                controller.toggleFavorite(for: event)
                
                didComplete(true)
                }))
            
            actions.append(favoriteEvent)
        }
        
        var shareItems = [url, message]
        
        if event.socialDescription.isEmpty == false {
            
            shareItems.append(event.socialDescription)
        }
        
        return ContextMenu(actions: actions, shareItems: shareItems, systemActions: false)
    }
    
    func feedbackController(for event: EventDetail, rating: Int? = nil, completion: (FeedbackViewController -> ())? = nil) -> UINavigationController {
        
        let feedbackViewController = R.storyboard.feedback.feedbackViewController()!
        
        feedbackViewController.completion = completion
        
        feedbackViewController.event = event.identifier
        
        if let rating = rating {
            
            let _ = feedbackViewController.view
            
            feedbackViewController.ratingView.rating = Double(rating)
        }
        
        let navigationController = UINavigationController(rootViewController: feedbackViewController)
        
        navigationController.modalPresentationStyle = .FormSheet
        
        return navigationController
    }
    
    func toggleScheduledStatus(for event: EventDetail) {
        
        let scheduled = Store.shared.isEventScheduledByLoggedMember(event: event.identifier)
        
        let rsvpURL = event.rsvp.isEmpty ? nil : NSURL(string: event.rsvp)
        
        let externalRSVP = event.externalRSVP
        
        let newValue = !scheduled
        
        // different action based on conditions
        switch (newValue, rsvpURL, externalRSVP) {
            
        // non-RSVP
        case let (newValue, .None, externalRSVP):
            
            assert(externalRSVP == false, "External RSVP should always have RSVP urls")
            
            // add / remove from schedule
            
            let request = newValue ? Store.shared.addEventToSchedule : Store.shared.removeEventFromSchedule
            
            // update cache immediately and add to schedule
            setScheduledOnServer(request, for: event, cacheValue: newValue) { }
            
        // external RSVP
        case let (newValue, .Some(url), true):
            
            // rsvp_external (boolean) if true, then before redirect to WEBView, mobile app should add the event to my schedule calling API ( this is only for attendees)
            
            // When event has external RSVP, clicking unRSVP button pings unSCHEDULE endpoint.
            // In this case, we do redirect to RSVP link (so, external RSVP redirects both when doing RSVP and unRSVP)
            
            let request = newValue ? Store.shared.addEventToSchedule : Store.shared.removeEventFromSchedule
            
            // update cache immediately, add to schedule and open RSVP link
            setScheduledOnServer(request, for: event, cacheValue: newValue) { UIApplication.sharedApplication().openURL(url) }
            
        // internal RSVPing
        case let (true, .Some(url), false):
            
            // just open RSVP link
            UIApplication.sharedApplication().openURL(url)
          
        // internal unRSVPing
        case (false, .Some, false):
            
            // When event has internal RSVP, clicking unRSVP button needs to ping the unRSVP endpoint 
            // (replacing the unSCHEDULE call since its done automatically by the server).
            // In this case, we dont need to redirect to RSVP link.
            setScheduledOnServer(Store.shared.removeRSVP, for: event) { }
        }
    }
    
    private func setScheduledLocally(value: Bool, for event: Identifier) {
        
        guard let attendee = Store.shared.authenticatedMember?.attendeeRole
            else { return }
        
        // update model
        if let managedObject = try! EventManagedObject.find(event, context: Store.shared.managedObjectContext) {
            
            if value {
                
                attendee.schedule.insert(managedObject)
                
            } else {
                
                attendee.schedule.remove(managedObject)
            }
        }
    }
    
    private typealias EventRequest = (summit: Identifier?, event: Identifier, completion: (ErrorType?) -> ()) -> ()
    
    private func setScheduledOnServer(request: EventRequest, for event: EventDetail, cacheValue: Bool? = nil, success: () -> ()) {
        
        let completion: ErrorType? -> () = { [weak self] (response) in
            
            NSOperationQueue.mainQueue().addOperationWithBlock {
                
                guard let controller = self else { return }
                
                controller.eventRequestInProgress = false
                
                switch response {
                    
                case let .Some(error):
                    
                    // restore original value
                    if let cacheValue = cacheValue {
                        
                        controller.setScheduledLocally(!cacheValue, for: event.identifier)
                    }
                    
                    // show error
                    controller.showErrorMessage(error)
                    
                case .None:
                    
                    // handle success
                    success()
                }
            }
        }
        
        // set new value immediately in cache
        if let cacheValue = cacheValue {
            
            self.setScheduledLocally(cacheValue, for: event.identifier)
        }
        
        eventRequestInProgress = true
        
        // make API request
        request(summit: event.summit, event: event.identifier, completion: completion)
    }
    
    func toggleFavorite(for event: EventDetail) {
        
       let isFavorite = Store.shared.authenticatedMember?.isFavorite(event: event.identifier) ?? false
        
        guard eventRequestInProgress == false else { return }
        
        eventRequestInProgress = true
        
        func setFavorite(newValue: Bool) {
            
            // update model
            if let managedObject = try! EventManagedObject.find(event.identifier, context: Store.shared.managedObjectContext) {
                
                if newValue {
                    
                    Store.shared.authenticatedMember?.favoriteEvents.insert(managedObject)
                    
                } else {
                    
                    Store.shared.authenticatedMember?.favoriteEvents.remove(managedObject)
                }
            }
        }
        
        setFavorite(!isFavorite)
        
        Store.shared.favorite(!isFavorite, event: event.identifier, summit: event.summit) { [weak self] (response) in
            
            NSOperationQueue.mainQueue().addOperationWithBlock {
                
                guard let controller = self else { return }
                
                controller.eventRequestInProgress = false
                
                switch response {
                    
                case let .Some(error):
                    
                    // show error
                    controller.showErrorMessage(error)
                    
                    // restore old value
                    setFavorite(isFavorite)
                    
                case .None: break
                }
            }
        }
    }
    
    func addToCalendar(event: EventDetail) {
        
        let status = EKEventStore.authorizationStatusForEntityType(.Event)
        
        switch status {
            
        case .Restricted, .Denied:
            
            break
            
        case .NotDetermined:
            
            eventStore.requestAccessToEntityType(.Event) { [weak self] (granted, error) in
                
                // retry
                self?.addToCalendar(event)
            }
        
        case .Authorized:
            
            let calendarListTitle = "OpenStack Summit"
            
            // get calendar
            
            let calendar: EKCalendar
            
            if let existingCalendar = eventStore.calendarsForEntityType(.Event).firstMatching({ $0.title == calendarListTitle }) {
                
                calendar = existingCalendar
                
            } else {
                
                calendar = EKCalendar(forEntityType: .Event, eventStore: eventStore)
                
                calendar.title = calendarListTitle
                
                calendar.source = eventStore.defaultCalendarForNewEvents.source
                
                do { try eventStore.saveCalendar(calendar, commit: true) }
                
                catch {
                    
                    showErrorMessage(error, fileName: #file, lineNumber: #line)
                    return
                }
            }
            
            // create event
            
            let calendarEvent = EKEvent(eventStore: eventStore)
            
            calendarEvent.calendar = calendar
            calendarEvent.title = event.name
            calendarEvent.startDate = event.start.toFoundation()
            calendarEvent.endDate = event.end.toFoundation()
            calendarEvent.timeZone = NSTimeZone(name: event.timeZone)
            calendarEvent.URL = event.webpageURL
            calendarEvent.location = event.location
            
            if let data = event.eventDescription.dataUsingEncoding(NSUTF8StringEncoding),
                let attributedString = try? NSAttributedString(data: data, options: [NSDocumentTypeDocumentAttribute:NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute:NSUTF8StringEncoding], documentAttributes: nil) {
                
                calendarEvent.notes = attributedString.string
            }
            
            do { try eventStore.saveEvent(calendarEvent, span: .ThisEvent, commit: true) }
                
            catch { showErrorMessage(error, fileName: #file, lineNumber: #line) }
        }
    }
}

