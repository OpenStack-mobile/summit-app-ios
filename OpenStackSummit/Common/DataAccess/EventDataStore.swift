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
    func getByFilterLocal(startDate: NSDate, endDate: NSDate, eventTypes: [Int]?, summitTypes: [Int]?)->[SummitEvent]
}

public class EventDataStore: GenericDataStore, IEventDataStore {
    public override init() {
        super.init()
    }
    
    public func getByIdLocal(id: Int) -> SummitEvent? {
        return super.getByIdLocal(id)
    }
    
    public func getByFilterLocal(startDate: NSDate, endDate: NSDate, eventTypes: [Int]?, summitTypes: [Int]?)->[SummitEvent]{
        var events = realm.objects(SummitEvent).filter("start >= %@ and end <= %@", startDate, endDate).sorted("start")
        if (eventTypes != nil) {
            events = events.filter("eventType.id in %@", eventTypes!)
        }

        var eventArray = events.map{$0}
        if (summitTypes != nil) {
            eventArray = eventArray.filter() {
                for summitTypeId in summitTypes! {
                    print($0.summitTypes.map{$0.id})
                    guard ($0.summitTypes.map{$0.id}.contains(summitTypeId)) else {
                        return false
                    }
                }
                return true
            }
        }
    
        return eventArray
    }
}
