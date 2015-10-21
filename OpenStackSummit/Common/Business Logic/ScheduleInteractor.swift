//
//  ScheduleInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/14/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IScheduleInteractor {
    func getActiveSummit(completionBlock: (SummitDTO?, NSError?) -> Void)
    func getScheduleEvents(startDate: NSDate, endDate: NSDate, eventTypes: [Int]?, summitTypes: [Int]?, tracks: [Int]?) -> [ScheduleItemDTO]
    func addEventToLoggedInMemberSchedule(eventId: Int, completionBlock: (NSError?) -> Void)
    func removeEventFromLoggedInMemberSchedule(eventId: Int, completionBlock: (NSError?) -> Void)
    func isEventScheduledByLoggedMember(eventId: Int) -> Bool
    func isMemberLoggedIn() -> Bool
}

public class ScheduleInteractor: NSObject {
    var summitDataStore: ISummitDataStore!
    var summitDTOAssembler: ISummitDTOAssembler!
    var eventDataStore: IEventDataStore!
    var scheduleItemDTOAssembler: IScheduleItemDTOAssembler!
    var securityManager: SecurityManager!
    var summitAttendeeDataStore: ISummitAttendeeDataStore!
    
    public func getActiveSummit(completionBlock: (SummitDTO?, NSError?) -> Void) {
        summitDataStore.getActive() { summit, error in
            var summitDTO: SummitDTO?
            if (error == nil) {
                summitDTO = self.summitDTOAssembler.createDTO(summit!)
            }
            completionBlock(summitDTO, error)
        }
    }
    
    public func getScheduleEvents(startDate: NSDate, endDate: NSDate, eventTypes: [Int]?, summitTypes: [Int]?, tracks: [Int]?) -> [ScheduleItemDTO] {
        let events = eventDataStore.getByFilterLocal(startDate, endDate: endDate, eventTypes: eventTypes, summitTypes: summitTypes, tracks: tracks)
        var scheduleItemDTO: ScheduleItemDTO
        var dtos: [ScheduleItemDTO] = []
        for event in events {
            scheduleItemDTO = scheduleItemDTOAssembler.createDTO(event)
            dtos.append(scheduleItemDTO)
        }
        return dtos
    }
    
    public func addEventToLoggedInMemberSchedule(eventId: Int, completionBlock: (NSError?) -> Void) {
        let loggedInMember = securityManager.getCurrentMember()
        let event = eventDataStore.getByIdLocal(eventId)
        
        summitAttendeeDataStore.addEventToMemberShedule(loggedInMember!.attendeeRole!, event: event!) {(attendee, error) in
            completionBlock(error)
        }
    }
    
    public func removeEventFromLoggedInMemberSchedule(eventId: Int, completionBlock: (NSError?) -> Void) {
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
