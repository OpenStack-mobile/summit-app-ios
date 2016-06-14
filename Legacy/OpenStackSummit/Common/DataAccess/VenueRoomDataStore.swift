//
//  VenueRoomDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/7/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import CoreSummit

public protocol VenueRoomDataStoreProtocol {
    func getByIdLocal(id: Int) -> RealmVenueRoom?
}

public final class VenueRoomDataStore: GenericDataStore, VenueRoomDataStoreProtocol {
    
    public func getByIdLocal(id: Int) -> RealmVenueRoom? {
        return super.getByIdLocal(id)
    }
}
