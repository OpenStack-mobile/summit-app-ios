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
    func getVenueRoom(venueRoomId: Int) -> VenueRoomDetailDTO?
}

public class VenueRoomDetailInteractor: NSObject, IVenueRoomDetailInteractor {
    var venueRoomDataStore: IVenueRoomDataStore!
    var venueRoomDetailDTOAssembler: IVenueRoomDetailDTOAssembler!

    public func getVenueRoom(venueRoomId: Int) -> VenueRoomDetailDTO? {
        let venueRoom = venueRoomDataStore.getByIdLocal(venueRoomId)
        let venueRoomDetailDTO = venueRoomDetailDTOAssembler.createDTO(venueRoom!)

        return venueRoomDetailDTO
    }
}
