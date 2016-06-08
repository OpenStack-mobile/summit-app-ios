//
//  GeneralScheduleInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/27/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import RealmSwift
import CoreSummit

public protocol GeneralScheduleFilterInteractorProtocol {
    func getSummitTypes() -> [Named]
    func getEventTypes() -> [Named]
    func getTracks() -> [Named]
    func getTrackGroups() -> [Named]
    func getLevels() -> [String]
    func getTagsBySearchTerm(searchTerm: String) -> [String]
    func getTrackGroup(id: Int) -> RealmTrackGroup?
}

public final class GeneralScheduleFilterInteractor: GeneralScheduleFilterInteractorProtocol {
    
    var summitTypeDataStore = SummitTypeDataStore()
    var eventTypeDataStore = EventTypeDataStore()
    var trackDataStore = TrackDataStore()
    var trackGroupDataStore = TrackGroupDataStore()
    var tagDataStore = TagDataStore()
    var eventDataStore = EventDataStore()
    
    public func getSummitTypes() -> [Named] {
        let entities = summitTypeDataStore.getAllLocal().sort({ $0.name < $1.name })
        return SummitType.from(realm: entities).map { $0 }
    }
   
    public func getEventTypes() -> [Named] {
        let entities = eventTypeDataStore.getAllLocal().sort({ $0.name < $1.name })
        return SummitType.from(realm: entities).map { $0 }
    }
    
    public func getTracks() -> [Named] {
        let entities = trackDataStore.getAllLocal().sort({ $0.name < $1.name })
        return Track.from(realm: entities).map { $0 }
    }
    
    public func getTrackGroups() -> [Named] {
        let entities = trackGroupDataStore.getAllLocal().sort({ $0.name < $1.name })
        return TrackGroup.from(realm: entities).map { $0 }
    }
    
    public func getLevels() -> [String] {
        return eventDataStore.getPresentationLevels()
    }

    public func getTags() -> [Named] {
        let entities = tagDataStore.getAllLocal()
        return Tag.from(realm: entities).map { $0 }
    }
    
    public func getTagsBySearchTerm(searchTerm: String) -> [String] {
        let entities = tagDataStore.getTagsBySearchTerm(searchTerm)
        return Array(
            Set(entities.map { $0.name.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) }) // unique values trimming tags
        ).sort()
    }
    
    public func getTrackGroup(id: Int) -> RealmTrackGroup? {
        return trackGroupDataStore.getByIdLocal(id)
    }
}
