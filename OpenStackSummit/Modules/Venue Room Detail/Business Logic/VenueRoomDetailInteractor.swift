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
    func getVenueRoom(venueRoomId: Int) -> VenueRoomDTO?
}

public class VenueRoomDetailInteractor: NSObject, IVenueRoomDetailInteractor {
    var venueRoomDataStore: IVenueRoomDataStore!
    var venueRoomDTOAssembler: IVenueRoomDTOAssembler!

    public func getVenueRoom(venueRoomId: Int) -> VenueRoomDTO? {
        let venueRoom = venueRoomDataStore.getByIdLocal(venueRoomId)
        let venueRoomDTO = venueRoomDTOAssembler.createDTO(venueRoom!)

        return venueRoomDTO
    }
}
