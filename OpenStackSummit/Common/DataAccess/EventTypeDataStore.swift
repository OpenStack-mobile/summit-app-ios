//
//  EventTypeDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/27/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public protocol IEventTypeDataStore {
    func getAll() -> [EventType]
}

public class EventTypeDataStore: BaseDataStore<EventType>, IEventTypeDataStore {
}
