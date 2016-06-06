//
//  ISchedueableInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 11/10/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//


import Foundation

public protocol ScheduleableInteractorProtocol {
    
    func addEventToLoggedInMemberSchedule(eventId: Int, completionBlock: (NSError?) -> Void)
    func removeEventFromLoggedInMemberSchedule(eventId: Int, completionBlock: (NSError?) -> Void)
    func isEventScheduledByLoggedMember(eventId: Int) -> Bool
    func isMemberLoggedIn() -> Bool
    func isLoggedInAndConfirmedAttendee() -> Bool
}

public class ScheduleableInteractor: ScheduleableInteractorProtocol {
    
    // MARK: - Properties
    
    var summitAttendeeDataStore: SummitAttendeeDataStore!
    var securityManager: SecurityManager!
    var eventDataStore: EventDataStore!
    var reachability: Reachability!
    
    // MARK: - Methods

    public func addEventToLoggedInMemberSchedule(eventId: Int, completionBlock: (NSError?) -> Void) {
        if !reachability.isConnectedToNetwork() {
            let error = NSError(domain: "There is no network connectivity. Operation cancelled", code: 12002, userInfo: nil)
            completionBlock(error)
            return
        }

        if let loggedInMember = securityManager.getCurrentMember() {
            let event = eventDataStore.getByIdLocal(eventId)
            
            summitAttendeeDataStore.addEventToMemberSchedule(loggedInMember.attendeeRole!, event: event!) {(attendee, error) in
                completionBlock(error)
            }
        }
    }
    
    public func removeEventFromLoggedInMemberSchedule(eventId: Int, completionBlock: (NSError?) -> Void) {
        if !reachability.isConnectedToNetwork() {
            let error = NSError(domain: "There is no network connectivity. Operation cancelled", code: 12001, userInfo: nil)
            completionBlock(error)
            return
        }

        if let loggedInMember = securityManager.getCurrentMember() {
            let event = eventDataStore.getByIdLocal(eventId)
            
            summitAttendeeDataStore.removeEventFromMemberSchedule(loggedInMember.attendeeRole!, event: event!) {(attendee, error) in
                completionBlock(error)
            }
        }
    }
    
    public func isEventScheduledByLoggedMember(eventId: Int) -> Bool {
        if !securityManager.isLoggedInAndConfirmedAttendee() {
            return false;
        }
            
        guard let loggedInMember = securityManager.getCurrentMember() else {
            return false
        }
        
        return loggedInMember.attendeeRole!.scheduledEvents.filter("id = \(eventId)").count > 0
    }
    
    public func isMemberLoggedIn() -> Bool {
        return securityManager.isLoggedIn()
    }
    
    public func isLoggedInAndConfirmedAttendee() -> Bool {
        return securityManager.isLoggedInAndConfirmedAttendee()
    }
}
