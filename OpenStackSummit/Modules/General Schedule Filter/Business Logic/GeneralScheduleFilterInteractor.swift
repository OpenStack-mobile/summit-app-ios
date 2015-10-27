//
//  GeneralScheduleInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/27/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import RealmSwift

@objc
public protocol IGeneralScheduleFilterInteractor {
    func getSummitTypes() -> [SummitType]
    func getEventTypes() -> [EventType]
    func getSummitTracks() -> [Track]
}

public class GeneralScheduleFilterInteractor: NSObject {
    
    var summitTypeDataStore: ISummitTypeDataStore!
    var eventTypeDataStore: IEventTypeDataStore!
    var trackDataStore: ITrackDataStore!
    
    public func getSummitTypes() -> [SummitType] {
        return summitTypeDataStore.getAllLocal()
    }
   
    public func getEventTypes() -> [EventType] {
        return eventTypeDataStore.getAllLocal()
    }
    
    public func getSummitTracks() -> [Track] {
        return trackDataStore.getAllLocal()
    }
}
