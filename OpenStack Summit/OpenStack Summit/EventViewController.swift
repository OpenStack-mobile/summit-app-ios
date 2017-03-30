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
        
        var shareItems = [message, url]
        
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
        
        // just open RSVP link
        guard rsvpURL == nil || event.externalRSVP else {
            
            UIApplication.sharedApplication().openURL(rsvpURL!)
            return
        }
        
        guard let attendee = Store.shared.authenticatedMember?.attendeeRole
            else { return }
        
        guard eventRequestInProgress == false else { return }
        
        eventRequestInProgress = true
        
        func setScheduled(newValue: Bool) {
            
            // update model
            if let managedObject = try! EventManagedObject.find(event.identifier, context: Store.shared.managedObjectContext) {
                
                if newValue {
                    
                    attendee.schedule.insert(managedObject)
                    
                } else {
                    
                    attendee.schedule.remove(managedObject)
                }
            }
        }
        
        setScheduled(!scheduled)
        
        let completion: ErrorType? -> () = { [weak self] (response) in
            
            NSOperationQueue.mainQueue().addOperationWithBlock {
                
                guard let controller = self else { return }
                
                controller.eventRequestInProgress = false
                
                switch response {
                    
                case let .Some(error):
                    
                    // restore original value
                    setScheduled(scheduled)
                    
                    // show error
                    controller.showErrorMessage(error)
                    
                case .None:
                    
                    if let url = rsvpURL {
                        
                        UIApplication.sharedApplication().openURL(url)
                    }
                }
            }
        }
        
        if scheduled {
            
            Store.shared.removeEventFromSchedule(event.summit, event: event.identifier, completion: completion)
            
        } else {
            
            Store.shared.addEventToSchedule(event.summit, event: event.identifier, completion: completion)
        }
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

