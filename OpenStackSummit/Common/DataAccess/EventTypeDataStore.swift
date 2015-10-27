//
//  EventTypeDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/27/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IEventTypeDataStore {
    func getAllLocal() -> [EventType]
}

public class EventTypeDataStore: GenericDataStore, IEventTypeDataStore {
    public func getAllLocal() -> [EventType] {
        return super.getAllLocal()
    }
}
