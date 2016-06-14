//
//  PersonalScheduleInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/17/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import CoreSummit

public protocol PersonalScheduleInteractorProtocol: ScheduleInteractorProtocol {
    
    func getLoggedInMemberScheduledEventsDatesFrom(startDate: NSDate, to endDate: NSDate) -> [NSDate]
    func getLoggedInMemberScheduledEventsFrom(startDate: NSDate, to endDate: NSDate) -> [ScheduleItem]
}

public class PersonalScheduleInteractor: ScheduleInteractor, PersonalScheduleInteractorProtocol {
    
    public func getLoggedInMemberScheduledEventsDatesFrom(startDate: NSDate, to endDate: NSDate) -> [NSDate] {
        let currentMember = securityManager.getCurrentMember()
        let events = currentMember?.attendeeRole?.scheduledEvents.filter("start >= %@ and end <= %@", startDate, endDate).sorted("start")
        
        var activeDates: [NSDate] = []
        for event in events! {
            let timeZone = NSTimeZone(name: event.summit.timeZone)!
            let startDate = event.start.mt_dateSecondsAfter(timeZone.secondsFromGMT).mt_startOfCurrentDay()
            if !activeDates.contains(startDate) {
                activeDates.append(startDate)
            }
            
        }
        return activeDates
    }
    
    public func getLoggedInMemberScheduledEventsFrom(startDate: NSDate, to endDate: NSDate) -> [ScheduleItem] {
        let currentMember = securityManager.getCurrentMember()
        let events = currentMember?.attendeeRole?.scheduledEvents.filter("start >= %@ and end <= %@", startDate, endDate).sorted("start")!
        
        return events.map { ScheduleItem(event: $0) }
        
        var ScheduleItem: ScheduleItem
        var dtos: [ScheduleItem] = []
        for event in events {
            ScheduleItem = ScheduleItemAssembler.createDTO(event)
            dtos.append(ScheduleItem)
        }
        return dtos
    }
}
