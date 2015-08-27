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
    
    var summitDataStore: ISummitDataStore!
    var delegate: IGeneralScheduleFilterPresenter!
    
    public func getSummitTypes() -> [SummitType] {
        return [SummitType]()
    }
   
    public func getEventTypes() -> [EventType] {
        return [EventType]()
    }
    
    public func getSummitTracks() -> [Track] {
        return [Track]()
    }
}
