//
//  VenueRoomDetailInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/7/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IVenueRoomDetailInteractor {
    func getVenueRoom(venueRoomId: Int) -> VenueRoom?
}

public class VenueRoomDetailInteractor: NSObject, IVenueRoomDetailInteractor {
    var venueRoomDataStore: IVenueRoomDataStore!

    public func getVenueRoom(venueRoomId: Int) -> VenueRoom? {
        return venueRoomDataStore.getById(venueRoomId)
    }
}
