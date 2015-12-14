//
//  ISchedueableInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 11/10/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IScheduleableInteractor {
    func addEventToLoggedInMemberSchedule(eventId: Int, completionBlock: (NSError?) -> Void)
    func removeEventFromLoggedInMemberSchedule(eventId: Int, completionBlock: (NSError?) -> Void)
    func isEventScheduledByLoggedMember(eventId: Int) -> Bool
    func isMemberLoggedIn() -> Bool
}

public class ScheduleableInteractor: NSObject, IScheduleableInteractor {
    var summitAttendeeDataStore: ISummitAttendeeDataStore!
    var securityManager: SecurityManager!
    var eventDataStore: IEventDataStore!
    var reachability: IReachability!

    public func addEventToLoggedInMemberSchedule(eventId: Int, completionBlock: (NSError?) -> Void) {
        if !reachability.isConnectedToNetwork() {
            let error = NSError(domain: "There is no network connectivity. Operation cancelled", code: 12002, userInfo: nil)
            completionBlock(error)
            return
        }

        let loggedInMember = securityManager.getCurrentMember()
        let event = eventDataStore.getByIdLocal(eventId)
        
        summitAttendeeDataStore.addEventToMemberShedule(loggedInMember!.attendeeRole!, event: event!) {(attendee, error) in
            completionBlock(error)
        }
    }
    
    public func removeEventFromLoggedInMemberSchedule(eventId: Int, completionBlock: (NSError?) -> Void) {
        if !reachability.isConnectedToNetwork() {
            let error = NSError(domain: "There is no network connectivity. Operation cancelled", code: 12001, userInfo: nil)
            completionBlock(error)
            return
        }

        let loggedInMember = securityManager.getCurrentMember()
        let event = eventDataStore.getByIdLocal(eventId)
        
        summitAttendeeDataStore.removeEventFromMemberShedule(loggedInMember!.attendeeRole!, event: event!) {(attendee, error) in
            completionBlock(error)
        }
    }
    
    public func isEventScheduledByLoggedMember(eventId: Int) -> Bool {
        guard let loggedInMember = securityManager.getCurrentMember() else {
            return false
        }
        
        return loggedInMember.attendeeRole!.scheduledEvents.filter("id = \(eventId)").count > 0
    }
    
    public func isMemberLoggedIn() -> Bool {
        return securityManager.isLoggedIn()
    }
}
