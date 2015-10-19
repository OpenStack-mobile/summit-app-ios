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
    func getLoggedInMemberScheduledEventsFrom(startDate: NSDate, to endDate: NSDate) -> [ScheduleItemDTO]
}

public class PersonalScheduleInteractor: ScheduleInteractor, IPersonalScheduleInteractor {
    
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
