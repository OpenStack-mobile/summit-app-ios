//
//  GeneralScheduleInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/27/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import RealmSwift

public protocol IGeneralScheduleFilterInteractor {
    func getSummitTypes() -> [SummitType]
    func getEventTypes() -> [EventType]
    func getSummitTracks() -> [Track]
}

public class GeneralScheduleFilterInteractor: NSObject {
    
    var summitTypeDataStore: ISummitTypeDataStore!
    var eventTypeDataStore: IEventTypeDataStore!
    var trackDataStore: ITrackDataStore!
    var delegate: IGeneralScheduleFilterPresenter!
    
    public func getSummitTypes() -> [SummitType] {
        return summitTypeDataStore.getAllFromLocal()
    }
   
    public func getEventTypes() -> [EventType] {
        return eventTypeDataStore.getAllFromLocal()
    }
    
    public func getSummitTracks() -> [Track] {
        return trackDataStore.getAllFromLocal()
    }
}
