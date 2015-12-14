//
//  SpeakerPresentationsInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/20/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol ISpeakerPresentationsInteractor: IScheduleInteractor {
    func getSpeakerPresentations(speakerId: Int, startDate: NSDate, endDate: NSDate) -> [ScheduleItemDTO]
}

public class SpeakerPresentationsInteractor: ScheduleInteractor, ISpeakerPresentationsInteractor {
    
    public func getSpeakerPresentations(speakerId: Int, startDate: NSDate, endDate: NSDate) -> [ScheduleItemDTO] {
        
        let events = eventDataStore.getSpeakerPresentationsLocal(speakerId, startDate: startDate, endDate: endDate)
        
        var scheduleItemDTO: ScheduleItemDTO
        var dtos: [ScheduleItemDTO] = []
        for event in events {
            scheduleItemDTO = scheduleItemDTOAssembler.createDTO(event)
            dtos.append(scheduleItemDTO)
        }
        return dtos
    }    
}
