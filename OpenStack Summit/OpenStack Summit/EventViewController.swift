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
        
        // Can give feedback after event started, and if there is no feedback for that user
        
        let eventID = NSNumber(longLong: Int64(event.identifier))
        
        let context = Store.shared.managedObjectContext
        
        guard let member = Store.shared.authenticatedMember
            else { return false }
        
        let predicate = NSPredicate(format: "event.id == %@ AND member == %@", eventID, member)
        
        return event.start < Date()
            && (try! context.count(FeedbackManagedObject.self, predicate: predicate)) == 0
    }
    
    func canAddToCalendar() -> Bool {
        
        let status = EKEventStore.authorizationStatusForEntityType(.Event)
        
        switch status {
        case .NotDetermined, .Authorized: return true
        case .Restricted, .Denied: return false
        }
    }
    
    func contextMenu(for event: EventDetail, scheduleableView: ScheduleableView? = nil) -> ContextMenu {
        
        guard let viewController = self as? UIViewController
            else { fatalError("\(self) is not a view controller") }
        
        let scheduled = Store.shared.isEventScheduledByLoggedMember(event: event.identifier)
        
        let message = "Check out this #OpenStack session I’m attending at the #OpenStackSummit!"
        
        let url = event.webpageURL
        
        var actions: [ContextMenu.Action] = []
        
        if canAddFeedback(for: event) {
            
            let image = "Rate"
            
            let rate = ContextMenu.Action(activityType: "Event.Rate", image: { UIImage(named: image)! }, title: "Rate", handler: .background({ [weak viewController] (didComplete) in
                
                guard let controller = viewController else { return }
                
                let feedbackVC = R.storyboard.feedback.feedbackEditViewController()!
                
                feedbackVC.event = event.identifier
                
                feedbackVC.rate = 0
                
                controller.showViewController(feedbackVC, sender: self)
                
                didComplete(true)
                }))
            
            actions.append(rate)
        }
        
        let isAttendee = Store.shared.isLoggedInAndConfirmedAttendee
        
        if isAttendee && eventRequestInProgress == false {
            
            let title: String
            
            if scheduled {
                
                title = "Confirmed"
                
            } else {
                
                title = event.rsvp.isEmpty ? "Confirm" : "RSVP"
            }
            
            let image = scheduled ? "CalendarRemove" : "CalendarAdd"
            
            let scheduleEvent = ContextMenu.Action(activityType: "Event.Schedule", image: { UIImage(named: image)! }, title: title, handler: .background({ [weak self] (didComplete) in
                
                guard let controller = self else { return }
                
                controller.toggleScheduledStatus(for: event, scheduleableView: scheduleableView)
                
                didComplete(true)
                }))
            
            actions.append(scheduleEvent)
        }
        
        if canAddToCalendar() {
            
            let image = "CalendarAddEmpty"
            
            let scheduleEvent = ContextMenu.Action(activityType: "Event.AddToCalendar", image: { UIImage(named: image)! }, title: "Add to Calendar", handler: .background({ [weak self] (didComplete) in
                
                guard let controller = self else { return }
                
                controller.addToCalendar(event)
                
                didComplete(true)
                }))
            
            actions.append(scheduleEvent)
        }
        
        let isFavorite = Store.shared.authenticatedMember?.isFavorite(event: event.identifier) ?? false
        
        if Store.shared.isLoggedIn {
            
            let title = isFavorite ? "Saved" : "Save"
            
            let image = isFavorite ? "Saved" : "Save"
            
            let favoriteEvent = ContextMenu.Action(activityType: "Event.Favorite", image: { UIImage(named: image)! }, title: title, handler: .background({ [weak self] (didComplete) in
                
                guard let controller = self else { return }
                
                controller.toggleFavorite(for: event)
                
                didComplete(true)
                }))
            
            actions.append(favoriteEvent)
        }
        
        return ContextMenu(actions: actions, shareItems: [message, url], systemActions: false)
    }
    
    func toggleScheduledStatus(for event: EventDetail, scheduleableView: ScheduleableView? = nil) {
        
        let scheduled = Store.shared.isEventScheduledByLoggedMember(event: event.identifier)
        
        guard eventRequestInProgress == false else { return }
        
        eventRequestInProgress = true
        
        // update view
        scheduleableView?.scheduled = !scheduled
        
        let completion: ErrorType? -> () = { [weak self] (response) in
            
            NSOperationQueue.mainQueue().addOperationWithBlock {
                
                guard let controller = self else { return }
                
                controller.eventRequestInProgress = false
                
                switch response {
                    
                case let .Some(error):
                    
                    // restore original value
                    scheduleableView?.scheduled = scheduled
                    
                    // show error
                    controller.showErrorMessage(error)
                    
                case .None: break
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
        
        Store.shared.favorite(!isFavorite, event: event.identifier, summit: event.summit) { [weak self] (response) in
            
            NSOperationQueue.mainQueue().addOperationWithBlock {
                
                guard let controller = self else { return }
                
                controller.eventRequestInProgress = false
                
                switch response {
                    
                case let .Some(error):
                    
                    // show error
                    controller.showErrorMessage(error)
                    
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

