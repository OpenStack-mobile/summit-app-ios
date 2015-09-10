//
//  GeneralScheduleInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/7/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IGeneralScheduleInteractor {
    func getScheduleEvents(completionBlock: ([SummitEvent]?, NSError?) -> Void)
    func getActiveSummit(completionBlock: (SummitDTO?, NSError?) -> Void)
    func getScheduleEventsForDate(startDate: NSDate, endDate: NSDate) -> [ScheduleItemDTO]
}

public class GeneralScheduleInteractor: NSObject, IGeneralScheduleInteractor {
    var summitDataStore: ISummitDataStore!
    var summitDTOAssembler: ISummitDTOAssembler!
    var eventDataStore: IEventDataStore!
    var scheduleItemDTOAssembler: IScheduleItemDTOAssembler!
    
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
    
    public func getScheduleEventsForDate(startDate: NSDate, endDate: NSDate) -> [ScheduleItemDTO] {
        let events = eventDataStore.getByDateRange(startDate, endDate: endDate)
        var scheduleItemDTO: ScheduleItemDTO
        var dtos: [ScheduleItemDTO] = []
        for event in events {
            scheduleItemDTO = scheduleItemDTOAssembler.createDTO(event)
            dtos.append(scheduleItemDTO)
        }
        return dtos
    }
}
