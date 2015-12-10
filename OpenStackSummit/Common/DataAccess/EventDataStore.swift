//
//  EventDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/28/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IEventDataStore {
    func getByIdLocal(id: Int) -> SummitEvent?
    func getByFilterLocal(startDate: NSDate, endDate: NSDate, eventTypes: [Int]?, summitTypes: [Int]?, tracks: [Int]?, tags: [String]?, levels:[String]?)->[SummitEvent]
    func getFeedback(eventId: Int, page: Int, objectsPerPage: Int, completionBlock : ([Feedback]?, NSError?) -> Void)
    func getBySearchTerm(searchTerm: String!)->[SummitEvent]
    func getPresentationLevels()->[String]
}

public class EventDataStore: GenericDataStore, IEventDataStore {
    var eventRemoteDataStore: IEventRemoteDataStore!
    
    public override init() {
        super.init()
    }
    
    public func getByIdLocal(id: Int) -> SummitEvent? {
        return super.getByIdLocal(id)
    }
    
    public func getByFilterLocal(startDate: NSDate, endDate: NSDate, eventTypes: [Int]?, summitTypes: [Int]?, tracks: [Int]?, tags: [String]?, levels: [String]?)->[SummitEvent]{
        var events = realm.objects(SummitEvent).filter("start >= %@ and end <= %@", startDate, endDate).sorted("start")
        if (eventTypes != nil && eventTypes!.count > 0) {
            events = events.filter("eventType.id in %@", eventTypes!)
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
        
        return events.map{$0}
    }
    
    public func getBySearchTerm(searchTerm: String!)->[SummitEvent] {
        let events = realm.objects(SummitEvent).filter("name CONTAINS [c]%@ or eventDescription CONTAINS [c]%@ or ANY tags.name CONTAINS [c]%@ or eventType.name CONTAINS [c]%@ or presentation.speakers.fullName CONTAINS [c]%@", searchTerm, searchTerm, searchTerm, searchTerm, searchTerm).sorted("start")
        return events.map { $0 }
    }
    
    public func getFeedback(eventId: Int, page: Int, objectsPerPage: Int, completionBlock : ([Feedback]?, NSError?) -> Void) {
        eventRemoteDataStore.getFeedbackForEvent(eventId, page: page, objectsPerPage: objectsPerPage, completionBlock: completionBlock)
    }
    
    public func getPresentationLevels()->[String] {
        let levels = realm.objects(Presentation).map { $0.level }
        let levelsSet = Set(levels)
        return Array(levelsSet)
    }
}
