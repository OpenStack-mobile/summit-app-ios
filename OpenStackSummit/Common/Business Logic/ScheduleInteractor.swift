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
    func getScheduleEvents(startDate: NSDate, endDate: NSDate, eventTypes: [Int]?, summitTypes: [Int]?, tracks: [Int]?, tags: [String]?, levels: [String]?) -> [ScheduleItemDTO]
    func addEventToLoggedInMemberSchedule(eventId: Int, completionBlock: (NSError?) -> Void)
    func removeEventFromLoggedInMemberSchedule(eventId: Int, completionBlock: (NSError?) -> Void)
    func isEventScheduledByLoggedMember(eventId: Int) -> Bool
    func subscribeToPushChannelsUsingContextIfNotDoneAlready()
}

public class ScheduleInteractor: ScheduleableInteractor {
    var summitDataStore: ISummitDataStore!
    var summitDTOAssembler: ISummitDTOAssembler!
    var scheduleItemDTOAssembler: IScheduleItemDTOAssembler!
    var dataUpdatePoller: DataUpdatePoller!
    var pushNotificationsManager: IPushNotificationsManager!
    var pushRegisterInProgress = false
    
    public func subscribeToPushChannelsUsingContextIfNotDoneAlready() {        
        if pushRegisterInProgress {
            return
        }
        
        pushRegisterInProgress = true
        
        if NSUserDefaults.standardUserDefaults().objectForKey("registeredPushNotificationChannels") == nil {
            self.pushNotificationsManager.subscribeToPushChannelsUsingContext(){ (succeeded: Bool, error: NSError?) in
                if succeeded {
                    NSUserDefaults.standardUserDefaults().setObject("true", forKey: "registeredPushNotificationChannels")
                }
                self.pushRegisterInProgress = false
            }
        }
    }
    
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
    
    public func getScheduleEvents(startDate: NSDate, endDate: NSDate, eventTypes: [Int]?, summitTypes: [Int]?, tracks: [Int]?, tags: [String]?, levels: [String]?) -> [ScheduleItemDTO] {
        let events = eventDataStore.getByFilterLocal(startDate, endDate: endDate, eventTypes: eventTypes, summitTypes: summitTypes, tracks: tracks, tags: tags, levels: levels)
        var scheduleItemDTO: ScheduleItemDTO
        var dtos: [ScheduleItemDTO] = []
        for event in events {
            scheduleItemDTO = scheduleItemDTOAssembler.createDTO(event)
            dtos.append(scheduleItemDTO)
        }
        return dtos
    }
}
