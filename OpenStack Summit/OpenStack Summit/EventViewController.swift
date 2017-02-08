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
    
    var addToScheduleInProgress: Bool { get set }
    
    var eventStore: EKEventStore { get }
}

extension EventViewController {
    
    func canAddFeedback(for event: EventDetail) -> Bool {
        
        // Can give feedback after event started, and if there is no feedback for that user
        
        let eventID = NSNumber(longLong: Int64(event.id))
        
        let context = Store.shared.managedObjectContext
        
        guard let member = Store.shared.authenticatedMember
            else { return false }
        
        let predicate = NSPredicate(format: "event.id == %@ AND member == %@", eventID, member)
        
        return event.start < Date()
            && (try! context.count(MemberFeedbackManagedObject.self, predicate: predicate)) == 0
            && (try! context.count(ReviewManagedObject.self, predicate: predicate)) == 0
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
        
        let scheduled = Store.shared.isEventScheduledByLoggedMember(event: event.id)
        
        let message = "Check out this #OpenStack session I’m attending at the #OpenStackSummit!"
        
        let url = event.webpageURL
        
        var actions: [ContextMenu.Action] = []
        
        if canAddFeedback(for: event) {
            
            let rate = ContextMenu.Action(activityType: "Event.Rate", image: nil, title: "Rate", handler: .background({ [weak viewController] (didComplete) in
                
                guard let controller = viewController else { return }
                
                let feedbackVC = R.storyboard.feedback.feedbackEditViewController()!
                
                feedbackVC.event = event.id
                
                feedbackVC.rate = 0
                
                controller.showViewController(feedbackVC, sender: self)
                
                didComplete(true)
                }))
            
            actions.append(rate)
        }
        
        let isAttendee = Store.shared.isLoggedInAndConfirmedAttendee
        
        if isAttendee && addToScheduleInProgress == false {
            
            let title = scheduled ? "Remove from Schedule" : "Add to Schedule"
            
            let scheduleEvent = ContextMenu.Action(activityType: "Event.Schedule", image: nil, title: title, handler: .background({ [weak self] (didComplete) in
                
                guard let controller = self else { return }
                
                controller.toggleScheduledStatus(for: event, scheduleableView: scheduleableView)
                
                didComplete(true)
                }))
            
            actions.append(scheduleEvent)
        }
        
        if canAddToCalendar() {
            
            let scheduleEvent = ContextMenu.Action(activityType: "Event.AddToCalendar", image: nil, title: "Add to Calendar", handler: .background({ [weak self] (didComplete) in
                
                guard let controller = self else { return }
                
                controller.addToCalendar(event)
                
                didComplete(true)
                }))
            
            actions.append(scheduleEvent)
        }
        
        return ContextMenu(actions: actions, shareItems: [message, url])
    }
    
    func toggleScheduledStatus(for event: EventDetail, scheduleableView: ScheduleableView? = nil) {
        
        let scheduled = Store.shared.isEventScheduledByLoggedMember(event: event.id)
        
        guard addToScheduleInProgress == false else { return }
        
        addToScheduleInProgress = true
        
        // update view
        scheduleableView?.scheduled = !scheduled
        
        let completion: ErrorType? -> () = { [weak self] (response) in
            
            guard let controller = self else { return }
            
            controller.addToScheduleInProgress = false
            
            switch response {
                
            case let .Some(error):
                
                // restore original value
                scheduleableView?.scheduled = scheduled
                
                // show error
                controller.showErrorMessage(error)
                
            case .None: break
            }
        }
        
        if scheduled {
            
            Store.shared.removeEventFromSchedule(event.summit, event: event.id, completion: completion)
            
        } else {
            
            Store.shared.addEventToSchedule(event.summit, event: event.id, completion: completion)
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

