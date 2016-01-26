//
//  VenueDataStore.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 1/26/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IVenueDataStore {
    func getByIdLocal(id: Int) -> Venue?
}

public class VenueDataStore: GenericDataStore, IVenueDataStore {
    public func getByIdLocal(id: Int) -> Venue? {
        let venue: Venue? = super.getByIdLocal(id)
        try! venue?.realm!.write {
            let sortedRooms = Array(venue!.venueRooms.sorted("name"))
            venue!.venueRooms.removeAll()
            venue!.venueRooms.appendContentsOf(sortedRooms)
        }
        return venue
    }
}
