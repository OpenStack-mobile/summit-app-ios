//
//  EventDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/28/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import RealmSwift

@objc
public protocol IEventDataStore {
    func getByIdLocal(id: Int) -> SummitEvent?
    func getByFilterLocal(startDate: NSDate, endDate: NSDate, eventTypes: [Int]?, summitTypes: [Int]?, tracks: [Int]?, trackGroups: [Int]?, tags: [String]?, levels:[String]?)->[SummitEvent]
    func getFeedback(eventId: Int, page: Int, objectsPerPage: Int, completionBlock : ([Feedback]?, NSError?) -> Void)
    func getBySearchTerm(searchTerm: String!)->[SummitEvent]
    func getPresentationLevels()->[String]
    func getSpeakerPresentationsLocal(speakerId: Int, startDate: NSDate, endDate: NSDate) -> [SummitEvent]
}

public class EventDataStore: GenericDataStore, IEventDataStore {
    var eventRemoteDataStore: IEventRemoteDataStore!
    let sortProperties = [SortDescriptor(property: "start", ascending: true), SortDescriptor(property: "end", ascending: true)]
    
    public func getByIdLocal(id: Int) -> SummitEvent? {
        return super.getByIdLocal(id)
    }
    
    public func getByFilterLocal(startDate: NSDate, endDate: NSDate, eventTypes: [Int]?, summitTypes: [Int]?, tracks: [Int]?, trackGroups: [Int]?, tags: [String]?, levels: [String]?)->[SummitEvent]{

        var events = realm.objects(SummitEvent).filter("start >= %@ and end <= %@", startDate, endDate).sorted(self.sortProperties)
        
        if (eventTypes != nil && eventTypes!.count > 0) {
            events = events.filter("eventType.id in %@", eventTypes!)
        }
        if (trackGroups != nil && trackGroups!.count > 0) {
            events = events.filter("presentation.track.trackGroup.id in %@", trackGroups!)
        }
        if (tracks != nil && tracks!.count > 0) {
            events = events.filter("presentation.track.id in %@", tracks!)
        }
        if (levels != nil && levels!.count > 0) {
            events = events.filter("presentation.level in %@", levels!)
        }

        if (summitTypes != nil && summitTypes!.count > 0) {
            for summitTypeId in summitTypes! {
                events = events.filter("ANY summitTypes.id = %@", summitTypeId)
            }
        }

        if (tags != nil && tags!.count > 0) {
            var tagsFilter = ""
            var separator = ""
            for tag in tags! {
                tagsFilter += "\(separator)ANY tags.name = '\(tag)'"
                separator = " OR "
            }
            events = events.filter(tagsFilter)
        }
        
        return events.map { $0 }
    }
    
    public func getBySearchTerm(searchTerm: String!)->[SummitEvent] {
        let events = realm.objects(SummitEvent).filter("name CONTAINS [c] %@ or eventDescription CONTAINS [c] %@ or presentation.speakers.fullName CONTAINS [c] %@ or presentation.level CONTAINS [c] %@ or ANY tags.name CONTAINS [c] %@ or eventType.name CONTAINS [c] %@", searchTerm, searchTerm, searchTerm, searchTerm, searchTerm, searchTerm).sorted(self.sortProperties)
        return events.map { $0 }
    }
    
    public func getFeedback(eventId: Int, page: Int, objectsPerPage: Int, completionBlock : ([Feedback]?, NSError?) -> Void) {
        eventRemoteDataStore.getFeedbackForEvent(eventId, page: page, objectsPerPage: objectsPerPage, completionBlock: completionBlock)
    }
    
    public func getPresentationLevels()->[String] {
        let levels = realm.objects(Presentation).map { $0.level }
        let levelsSet = Set(levels)
        let filteredArray = Array(levelsSet).sort()
        return filteredArray
    }
    
    public func getSpeakerPresentationsLocal(speakerId: Int, startDate: NSDate, endDate: NSDate) -> [SummitEvent] {
        let events = realm.objects(SummitEvent).filter("presentation.speakers.id = %@ && start >= %@ and end <= %@", speakerId, startDate, endDate).sorted(self.sortProperties)
        return events.map { $0 }
    }
    
}
