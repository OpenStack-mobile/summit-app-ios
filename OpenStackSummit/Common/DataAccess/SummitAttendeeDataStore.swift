//
//  SummitAttendeeDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/15/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol ISummitAttendeeDataStore {
    func addFeedback(attendee: SummitAttendee, feedback: Feedback, completionBlock : (Feedback?, NSError?)->Void)
    func addEventToMemberSchedule(attendee: SummitAttendee, event: SummitEvent, completionBlock : (SummitAttendee?, NSError?) -> Void)
    func removeEventFromMemberSchedule(attendee: SummitAttendee, event: SummitEvent, completionBlock : (SummitAttendee?, NSError?) -> Void)
}

public class SummitAttendeeDataStore: GenericDataStore, ISummitAttendeeDataStore {
    
    public override init() {
        super.init()
    }
    
    public init(summitAttendeeRemoteDataStore: ISummitAttendeeRemoteDataStore) {
        self.summitAttendeeRemoteDataStore = summitAttendeeRemoteDataStore
    }
    
    var summitAttendeeRemoteDataStore: ISummitAttendeeRemoteDataStore!
    
    public func addFeedback(attendee: SummitAttendee, feedback: Feedback, completionBlock : (Feedback?, NSError?)->Void) {
        summitAttendeeRemoteDataStore.addFeedback(attendee, feedback: feedback) {(feedback, error) in
            if (error != nil) {
                completionBlock(nil, error)
                return
            }
            
            try! self.realm.write{
                attendee.feedback.append(feedback!)
            }
            completionBlock(feedback, error)
        }
    }
    
    public func addEventToMemberSchedule(attendee: SummitAttendee, event: SummitEvent, completionBlock : (SummitAttendee?, NSError?) -> Void) {
        summitAttendeeRemoteDataStore.addEventToShedule(attendee, event: event) { error in
            
            if error != nil {
                return
            }
            
            self.addEventToMemberScheduleLocal(attendee, event: event)
            
            completionBlock(attendee, error)
        }
    }
    
    public func removeEventFromMemberSchedule(attendee: SummitAttendee, event: SummitEvent, completionBlock : (SummitAttendee?, NSError?) -> Void) {
        summitAttendeeRemoteDataStore.removeEventFromShedule(attendee, event: event) { error in
            var innerError = error
            
            defer { completionBlock(attendee, innerError) }
            
            if error != nil {
                return
            }
            
            do {
                try self.removeEventFromMemberScheduleLocal(attendee, event: event)
            }
            catch {
                innerError = NSError(domain: "There was an error removing event from member schedule", code: 1001, userInfo: nil)
            }
        }
    }
    
    public func addEventToMemberScheduleLocal(attendee: SummitAttendee, event: SummitEvent) {
        
        try! self.realm.write {
            let index = attendee.scheduledEvents.indexOf("id = %@", event.id)
            if (index == nil) {
                attendee.scheduledEvents.append(event)
            }
        }
    }
    
    public func removeEventFromMemberScheduleLocal(attendee: SummitAttendee, event: SummitEvent) throws {
        
        try! self.realm.write {
            let index = attendee.scheduledEvents.indexOf("id = %@", event.id)
            if (index != nil) {
                attendee.scheduledEvents.removeAtIndex(index!)
            }
        }
    }
}
