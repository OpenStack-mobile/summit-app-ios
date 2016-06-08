//
//  EventTypeDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/27/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import CoreSummit

public protocol EventTypeDataStoreProtocol {
    func getAllLocal() -> [RealmEventType]
}

public class EventTypeDataStore: GenericDataStore, EventTypeDataStoreProtocol {
    public func getAllLocal() -> [RealmEventType] {
        return super.getAllLocal()
    }
}
