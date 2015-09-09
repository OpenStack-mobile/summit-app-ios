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
    func getById(id: Int) -> SummitEvent?
}

public class EventDataStore: BaseDataStore<SummitEvent>, IEventDataStore {
    public override func getById(id: Int) -> SummitEvent? {
        return super.getById(id)
    }
}
