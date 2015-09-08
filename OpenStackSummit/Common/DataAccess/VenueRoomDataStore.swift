//
//  VenueRoomDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/7/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IVenueRoomDataStore {
    func get(id: Int) -> VenueRoom!
}

public class VenueRoomDataStore: BaseDataStore<VenueRoom>, IVenueRoomDataStore {
    public override func get(id: Int) -> VenueRoom? {
        return super.get(id)
    }
}
