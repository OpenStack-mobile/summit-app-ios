//
//  SpeakerPresentationsInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/20/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol ISpeakerPresentationsInteractor: ScheduleInteractorProtocol {
    func getSpeakerPresentationsDates(speakerId: Int, startDate: NSDate, endDate: NSDate) -> [NSDate]
    func getSpeakerPresentations(speakerId: Int, startDate: NSDate, endDate: NSDate) -> [ScheduleItem]
}

public class SpeakerPresentationsInteractor: ScheduleInteractor, ISpeakerPresentationsInteractor {
    
    public func getSpeakerPresentationsDates(speakerId: Int, startDate: NSDate, endDate: NSDate) -> [NSDate] {
        let events = eventDataStore.getSpeakerPresentationsLocal(speakerId, startDate: startDate, endDate: endDate)
        var activeDates: [NSDate] = []
        for event in events {
            let timeZone = NSTimeZone(name: event.summit.timeZone)!
            let startDate = event.start.mt_dateSecondsAfter(timeZone.secondsFromGMT).mt_startOfCurrentDay()
            if !activeDates.contains(startDate) {
                activeDates.append(startDate)
            }
            
        }
        return activeDates
    }
    
    public func getSpeakerPresentations(speakerId: Int, startDate: NSDate, endDate: NSDate) -> [ScheduleItem] {
        let events = eventDataStore.getSpeakerPresentationsLocal(speakerId, startDate: startDate, endDate: endDate)
        
        var ScheduleItem: ScheduleItem
        var dtos: [ScheduleItem] = []
        for event in events {
            ScheduleItem = ScheduleItemAssembler.createDTO(event)
            dtos.append(ScheduleItem)
        }
        return dtos
    }
    
}
