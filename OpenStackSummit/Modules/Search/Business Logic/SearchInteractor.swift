//
//  SearchInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/23/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol ISearchInteractor: ScheduleableInteractorProtocol {
    func getEventsBySearchTerm(searchTerm: String) -> [ScheduleItem]
    func getTracksBySearchTerm(searchTerm: String) -> [TrackDTO]
    func getSpeakersBySearchTerm(saerchTerm: String?, page: Int, objectsPerPage: Int, completionBlock : ([PersonListItemDTO]?, NSError?) -> Void)
    func getAttendeesBySearchTerm(saerchTerm: String?, page: Int, objectsPerPage: Int, completionBlock : ([PersonListItemDTO]?, NSError?) -> Void)
}

public class SearchInteractor: ScheduleableInteractor, ISearchInteractor {
    var ScheduleItemAssembler: IScheduleItemAssembler!
    var trackDataStore: ITrackDataStore!
    var trackDTOAssembler: NamedDTOAssembler!
    var presentationSpeakerDataStore: IPresentationSpeakerDataStore!
    var summitAttendeeRemoteDataStore: ISummitAttendeeRemoteDataStore!
    var personDTOAssembler: PersonListItemDTOAssembler!
    
    public func getSpeakersBySearchTerm(saerchTerm: String?, page: Int, objectsPerPage: Int, completionBlock : ([PersonListItemDTO]?, NSError?) -> Void) {
        let speakers = presentationSpeakerDataStore.getByFilterLocal(saerchTerm, page: page, objectsPerPage: objectsPerPage)
        getByFilterCallback(speakers, error: nil, completionBlock: completionBlock)
    }
    
    public func getAttendeesBySearchTerm(saerchTerm: String?, page: Int, objectsPerPage: Int, completionBlock : ([PersonListItemDTO]?, NSError?) -> Void) {
        summitAttendeeRemoteDataStore.getByFilter(saerchTerm, page: page, objectsPerPage: objectsPerPage) { (attendees, error) in
            self.getByFilterCallback(attendees, error: error, completionBlock: completionBlock)
        }
    }
    
    func getByFilterCallback<T: Person>(persons: [T]?, error: NSError?, completionBlock : ([PersonListItemDTO]?, NSError?) -> Void) {
        if (error != nil) {
            completionBlock(nil, error)
            return
        }
        
        var personListItemDTO: PersonListItemDTO
        var dtos: [PersonListItemDTO] = []
        for person in persons! {
            personListItemDTO = self.personDTOAssembler.createDTO(person)
            dtos.append(personListItemDTO)
        }
        
        completionBlock(dtos, error)
    }
    
    public func getEventsBySearchTerm(searchTerm: String) -> [ScheduleItem] {
        let events = eventDataStore.getBySearchTerm(searchTerm)
        var ScheduleItem: ScheduleItem
        var dtos: [ScheduleItem] = []
        for event in events {
            ScheduleItem = ScheduleItemAssembler.createDTO(event)
            dtos.append(ScheduleItem)
        }
        return dtos
    }
    
    public func getTracksBySearchTerm(searchTerm: String) -> [TrackDTO] {
        let tracks = trackDataStore.getBySearchTerm(searchTerm)
        var trackDTO: TrackDTO
        var dtos: [TrackDTO] = []
        for track in tracks {
            trackDTO = trackDTOAssembler.createDTO(track)
            dtos.append(trackDTO)
        }
        return dtos
    }
}
