//
//  VenueDTOAssembler.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/22/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IVenueDTOAssembler {
    func createDTO(venue: Venue) -> VenueDTO
}

public class VenueDTOAssembler: VenueListItemDTOAssembler, IVenueDTOAssembler {
    public override init() {
        super.init()
    }

    public init(venueRoomDTOAssembler: VenueRoomDTOAssembler) {
        self.venueRoomDTOAssembler = venueRoomDTOAssembler
    }
    
    var venueRoomDTOAssembler: IVenueRoomDTOAssembler!
    
    public override func createDTO(venue: Venue) -> VenueDTO {
        let venueDTO: VenueDTO = super.createDTO(venue)
        
        var venueRoomDTO: VenueRoomDTO
        for venueRoom in venue.venueRooms {
            venueRoomDTO = venueRoomDTOAssembler.createDTO(venueRoom)
            venueDTO.rooms.append(venueRoomDTO)
        }
        return venueDTO
    }
}

