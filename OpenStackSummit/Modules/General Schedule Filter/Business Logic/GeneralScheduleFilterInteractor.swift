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
    func getSummitTypes() -> [NamedDTO]
    func getEventTypes() -> [NamedDTO]
    func getTracks() -> [NamedDTO]
    func getTrackGroups() -> [NamedDTO]
    func getLevels() -> [String]
    func getTagsBySearchTerm(searchTerm: String) -> [String]
    func getTrackGroup(id: Int) -> TrackGroup?
}

public class GeneralScheduleFilterInteractor: NSObject {
    
    var summitTypeDataStore: ISummitTypeDataStore!
    var eventTypeDataStore: IEventTypeDataStore!
    var trackDataStore: ITrackDataStore!
    var trackGroupDataStore: ITrackGroupDataStore!
    var tagDataStore: ITagDataStore!
    var namedDTOAssembler: NamedDTOAssembler!
    var eventDataStore: IEventDataStore!
    var dataUpdatePoller: IDataUpdatePoller!

    public func getSummitTypes() -> [NamedDTO] {
        let entities = summitTypeDataStore.getAllLocal().sort({ $0.name < $1.name })
        return createDTOs(entities)
    }
   
    public func getEventTypes() -> [NamedDTO] {
        let entities = eventTypeDataStore.getAllLocal().sort({ $0.name < $1.name })
        return createDTOs(entities)
    }
    
    public func getTracks() -> [NamedDTO] {
        let entities = trackDataStore.getAllLocal().sort({ $0.name < $1.name })
        return createDTOs(entities)
    }
    
    public func getTrackGroups() -> [NamedDTO] {
        let entities = trackGroupDataStore.getAllLocal().sort({ $0.name < $1.name })
        return createDTOs(entities)
    }
    
    public func getLevels() -> [String] {
        return eventDataStore.getPresentationLevels()
    }

    public func getTags() -> [NamedDTO] {
        let entities = tagDataStore.getAllLocal()
        return createDTOs(entities)
    }
    
    public func getTagsBySearchTerm(searchTerm: String) -> [String] {
        let entities = tagDataStore.getTagsBySearchTerm(searchTerm)
        return Array(
            Set(entities.map { $0.name.lowercaseString.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceCharacterSet()) }) // unique values trimming tags
        ).sort()
    }
    
    public func createDTOs(entities: [NamedEntity]) -> [NamedDTO]{
        var dtos: [NamedDTO] = []
        var dto: NamedDTO
        for entity in entities {
            dto = namedDTOAssembler.createDTO(entity)
            dtos.append(dto)
        }
        return dtos
    }
    
    public func getTrackGroup(id: Int) -> TrackGroup? {
        return trackGroupDataStore.getByIdLocal(id)
    }
}
