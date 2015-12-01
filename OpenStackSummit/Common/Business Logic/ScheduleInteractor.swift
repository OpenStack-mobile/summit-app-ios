//
//  ScheduleInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/14/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IScheduleInteractor : IScheduleableInteractor {
    func getActiveSummit(completionBlock: (SummitDTO?, NSError?) -> Void)
    func getScheduleEvents(startDate: NSDate, endDate: NSDate, eventTypes: [Int]?, summitTypes: [Int]?, tracks: [Int]?, tags: [String]?) -> [ScheduleItemDTO]
    func addEventToLoggedInMemberSchedule(eventId: Int, completionBlock: (NSError?) -> Void)
    func removeEventFromLoggedInMemberSchedule(eventId: Int, completionBlock: (NSError?) -> Void)
    func isEventScheduledByLoggedMember(eventId: Int) -> Bool
}

public class ScheduleInteractor: ScheduleableInteractor {
    var summitDataStore: ISummitDataStore!
    var summitDTOAssembler: ISummitDTOAssembler!
    var scheduleItemDTOAssembler: IScheduleItemDTOAssembler!
    var dataUpdatePoller: DataUpdatePoller!
    
    public func getActiveSummit(completionBlock: (SummitDTO?, NSError?) -> Void) {
        summitDataStore.getActive() { summit, error in
            self.dataUpdatePoller.startPollingIfNotPollingAlready()

            var summitDTO: SummitDTO?
            if (error == nil) {
                summitDTO = self.summitDTOAssembler.createDTO(summit!)
            }
            completionBlock(summitDTO, error)
        }
    }
    
    public func getScheduleEvents(startDate: NSDate, endDate: NSDate, eventTypes: [Int]?, summitTypes: [Int]?, tracks: [Int]?, tags: [String]?) -> [ScheduleItemDTO] {
        let events = eventDataStore.getByFilterLocal(startDate, endDate: endDate, eventTypes: eventTypes, summitTypes: summitTypes, tracks: tracks, tags: tags)
        var scheduleItemDTO: ScheduleItemDTO
        var dtos: [ScheduleItemDTO] = []
        for event in events {
            scheduleItemDTO = scheduleItemDTOAssembler.createDTO(event)
            dtos.append(scheduleItemDTO)
        }
        return dtos
    }
}
