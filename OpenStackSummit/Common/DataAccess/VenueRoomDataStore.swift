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
    func getByIdLocal(id: Int) -> VenueRoom?
}

public class VenueRoomDataStore: GenericDataStore, IVenueRoomDataStore {
    public func getByIdLocal(id: Int) -> VenueRoom? {
        return super.getByIdLocal(id)
    }
}
