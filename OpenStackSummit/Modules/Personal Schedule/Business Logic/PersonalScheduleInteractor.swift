//
//  PersonalScheduleInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/17/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IPersonalScheduleInteractor: IScheduleInteractor {
    func getLoggedInMemberScheduledEventsDatesFrom(startDate: NSDate, to endDate: NSDate) -> [NSDate]
    func getLoggedInMemberScheduledEventsFrom(startDate: NSDate, to endDate: NSDate) -> [ScheduleItemDTO]
}

public class PersonalScheduleInteractor: ScheduleInteractor, IPersonalScheduleInteractor {
    
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
    
    public func getLoggedInMemberScheduledEventsFrom(startDate: NSDate, to endDate: NSDate) -> [ScheduleItemDTO] {
        let currentMember = securityManager.getCurrentMember()
        let events = currentMember?.attendeeRole?.scheduledEvents.filter("start >= %@ and end <= %@", startDate, endDate).sorted("start")
        
        var scheduleItemDTO: ScheduleItemDTO
        var dtos: [ScheduleItemDTO] = []
        for event in events! {
            scheduleItemDTO = scheduleItemDTOAssembler.createDTO(event)
            dtos.append(scheduleItemDTO)
        }
        return dtos
    }
}
