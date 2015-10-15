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
    func getScheduleEvents(completionBlock: ([SummitEvent]?, NSError?) -> Void)
    func getActiveSummit(completionBlock: (SummitDTO?, NSError?) -> Void)
    func getScheduleEvents(startDate: NSDate, endDate: NSDate, eventTypes: [Int]?, summitTypes: [Int]?) -> [ScheduleItemDTO]
    func addEventToLoggedInMemberSchedule(eventId: Int, completionBlock: (NSError?) -> Void)
    func removeEventFromLoggedInMemberSchedule(eventId: Int, completionBlock: (NSError?) -> Void)
    func isEventScheduledByLoggedUser(eventId: Int) -> Bool
}

public class ScheduleInteractor: NSObject {
    var summitDataStore: ISummitDataStore!
    var summitDTOAssembler: ISummitDTOAssembler!
    var eventDataStore: IEventDataStore!
    var scheduleItemDTOAssembler: IScheduleItemDTOAssembler!
    var securityManager: SecurityManager!
    var memberDataStore: IMemberDataStore!
    
    public func getActiveSummit(completionBlock: (SummitDTO?, NSError?) -> Void) {
        summitDataStore.getActive() { summit, error in
            var summitDTO: SummitDTO?
            if (error == nil) {
                summitDTO = self.summitDTOAssembler.createDTO(summit!)
            }
            completionBlock(summitDTO, error)
        }
    }
    
    public func getScheduleEvents(completionBlock: ([SummitEvent]?, NSError?) -> Void){
        summitDataStore.getActive() { summit, error in
            completionBlock(summit!.events.map{$0}, nil)
        }
    }
    
    public func getScheduleEvents(startDate: NSDate, endDate: NSDate, eventTypes: [Int]?, summitTypes: [Int]?) -> [ScheduleItemDTO] {
        let events = eventDataStore.getByFilterLocal(startDate, endDate: endDate, eventTypes: eventTypes, summitTypes: summitTypes)
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
        
        memberDataStore.addEventToMemberShedule(loggedInMember!, event: event!) {(member, error) in
            completionBlock(error)
        }
    }
    
    public func removeEventFromLoggedInMemberSchedule(eventId: Int, completionBlock: (NSError?) -> Void) {
        let loggedInMember = securityManager.getCurrentMember()
        let event = eventDataStore.getByIdLocal(eventId)
        
        memberDataStore.removeEventFromMemberShedule(loggedInMember!, event: event!) {(member, error) in
            completionBlock(error)
        }
    }
    
    public func isEventScheduledByLoggedUser(eventId: Int) -> Bool {
        guard let loggedInMember = securityManager.getCurrentMember() else {
            return false
        }
        
        return loggedInMember.attendeeRole!.scheduledEvents.filter("id = \(eventId)").count > 0
    }
}
