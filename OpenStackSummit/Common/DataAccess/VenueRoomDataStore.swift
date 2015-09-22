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
    func getByIdFromLocal(id: Int) -> VenueRoom?
}

public class VenueRoomDataStore: BaseDataStore<VenueRoom>, IVenueRoomDataStore {
    public func getByIdFromLocal(id: Int) -> VenueRoom? {
        return super.getById(id)
    }
}
