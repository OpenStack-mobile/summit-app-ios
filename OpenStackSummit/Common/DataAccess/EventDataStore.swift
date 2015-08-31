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
    func get(id: Int) -> SummitEvent?
}

public class EventDataStore: BaseDataStore<SummitEvent>, IEventDataStore {
    public override func get(id: Int) -> SummitEvent? {
        return super.get(id)
    }
}
