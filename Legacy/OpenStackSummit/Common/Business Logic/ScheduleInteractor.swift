//
//  ScheduleInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/14/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import CoreSummit

public protocol ScheduleInteractorProtocol: ScheduleableInteractorProtocol {
    
    func getActiveSummit(completionBlock: ErrorValue<Summit> -> ())
    func getScheduleAvailableDates(startDate: NSDate, endDate: NSDate, eventTypes: [Int]?, summitTypes: [Int]?, tracks: [Int]?, trackGroups: [Int]?, tags: [String]?, levels: [String]?) -> [NSDate]
    func getScheduleEvents(startDate: NSDate, endDate: NSDate, eventTypes: [Int]?, summitTypes: [Int]?, tracks: [Int]?, trackGroups: [Int]?, tags: [String]?, levels: [String]?) -> [ScheduleItem]
    func addEventToLoggedInMemberSchedule(eventId: Int, completionBlock: (NSError?) -> Void)
    func removeEventFromLoggedInMemberSchedule(eventId: Int, completionBlock: (NSError?) -> Void)
    func isEventScheduledByLoggedMember(eventId: Int) -> Bool
    func subscribeToPushChannelsUsingContextIfNotDoneAlready()
    func isDataLoaded() -> Bool
    func eventExist(id: Int) -> Bool
}

public final class ScheduleInteractor: ScheduleableInteractor, ScheduleInteractorProtocol {
    
    // MARK: - Properties
    
    public let summitDataStore: SummitDataStore = SummitDataStore()
    
    let dataUpdatePoller = DataUpdatePoller()
    let pushNotificationsManager = PushNotificationsManager()
    var pushRegisterInProgress = false
    
    // MARK: - Methods
    
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
    
    public func getActiveSummit(completion: ErrorValue<Summit> -> ()) {
        
        summitDataStore.getActive() { (response) in
            
            self.dataUpdatePoller.startPollingIfNotPollingAlready()
            
            guard error == nil
                else { completion(.Error(error!)); return }
            
            let summit = Summit(realmEntity: realmEntity)

            var summitDTO: Summit?
            if (error == nil) {
                summitDTO = self.summitDTOAssembler.createDTO(summit!)
            }
            completionBlock(Summit, error)
        }
    }
    
    public func getScheduleAvailableDates(startDate: NSDate, endDate: NSDate, eventTypes: [Int]?, summitTypes: [Int]?, tracks: [Int]?, trackGroups: [Int]?, tags: [String]?, levels: [String]?) -> [NSDate] {
        let events = eventDataStore.getByFilterLocal(startDate, endDate: endDate, eventTypes: eventTypes, summitTypes: summitTypes, tracks: tracks, trackGroups: trackGroups, tags: tags, levels: levels)
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
    
    public func getScheduleEvents(startDate: NSDate, endDate: NSDate, eventTypes: [Int]?, summitTypes: [Int]?, tracks: [Int]?, trackGroups: [Int]?, tags: [String]?, levels: [String]?) -> [ScheduleItem] {
        let events = eventDataStore.getByFilterLocal(startDate, endDate: endDate, eventTypes: eventTypes, summitTypes: summitTypes, tracks: tracks, trackGroups: trackGroups, tags: tags, levels: levels)
        var ScheduleItem: ScheduleItem
        var dtos: [ScheduleItem] = []
        for event in events {
            ScheduleItem = ScheduleItemAssembler.createDTO(event)
            dtos.append(ScheduleItem)
        }
        return dtos
    }
    
    public func isDataLoaded() -> Bool {
        let summit = summitDataStore.getActiveLocal()
        return summit != nil
    }
    
    public func eventExist(id: Int) -> Bool {
        let event = eventDataStore.getByIdLocal(id)
        return event != nil
    }
}
