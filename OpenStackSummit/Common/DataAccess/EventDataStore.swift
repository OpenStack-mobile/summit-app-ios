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
    func getByFilterLocal(startDate: NSDate, endDate: NSDate, eventTypes: [Int]?, summitTypes: [Int]?, tracks: [Int]?)->[SummitEvent]
    func getFeedback(eventId: Int, page: Int, objectsPerPage: Int, completionBlock : ([Feedback]?, NSError?) -> Void)
    func getBySearchTerm(searchTerm: String!)->[SummitEvent]
}

public class EventDataStore: GenericDataStore, IEventDataStore {
    var eventRemoteDataStore: IEventRemoteDataStore!
    
    public override init() {
        super.init()
    }
    
    public func getByIdLocal(id: Int) -> SummitEvent? {
        return super.getByIdLocal(id)
    }
    
    public func getByFilterLocal(startDate: NSDate, endDate: NSDate, eventTypes: [Int]?, summitTypes: [Int]?, tracks: [Int]?)->[SummitEvent]{
        var events = realm.objects(SummitEvent).filter("start >= %@ and end <= %@", startDate, endDate).sorted("start")
        if (eventTypes != nil && eventTypes!.count > 0) {
            events = events.filter("eventType.id in %@", eventTypes!)
        }
        if (tracks != nil && tracks!.count > 0) {
            events = events.filter("presentation.track.id in %@", tracks!)
        }

        if (summitTypes != nil && summitTypes!.count > 0) {
            for summitTypeId in summitTypes! {
                events = events.filter("ANY summitTypes.id = %@", summitTypeId)
            }
        }
    
        return events.map{$0}
    }
    
    public func getBySearchTerm(searchTerm: String!)->[SummitEvent] {
        let events = realm.objects(SummitEvent).filter("name CONTAINS [c]%@ or eventDescription CONTAINS [c]%@", searchTerm, searchTerm).sorted("start")
        return events.map { $0 }
    }
    
    public func getFeedback(eventId: Int, page: Int, objectsPerPage: Int, completionBlock : ([Feedback]?, NSError?) -> Void) {
        eventRemoteDataStore.getFeedbackForEvent(eventId, page: page, objectsPerPage: objectsPerPage, completionBlock: completionBlock)
    }
}
