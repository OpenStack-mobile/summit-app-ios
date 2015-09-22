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
    func getByIdFromLocal(id: Int) -> SummitEvent?
    func getByDateRangeFromLocal(startDate: NSDate, endDate: NSDate)->[SummitEvent]
}

public class EventDataStore: BaseDataStore<SummitEvent>, IEventDataStore {
    public func getByIdFromLocal(id: Int) -> SummitEvent? {
        return super.getById(id)
    }
    
    public func getByDateRangeFromLocal(startDate: NSDate, endDate: NSDate)->[SummitEvent]{
        let predicate = NSPredicate(format: "start > %@ and end < %@", startDate, endDate)
        let events = realm.objects(SummitEvent.self).filter(predicate)
        return events.map{$0}
    }
}
