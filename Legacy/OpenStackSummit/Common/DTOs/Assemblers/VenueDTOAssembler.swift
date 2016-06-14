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
    
    override public func createDTO(venue: Venue) -> VenueDTO {
        let venueDTO: VenueDTO = super.createDTO(venue)
        
        venueDTO.address = getAddress(venue)
        venueDTO.lat = Double(venue.lat)
        venueDTO.long = Double(venue.long)
        
        for map in venue.maps {
            venueDTO.maps.append(map.url)
        }
        
        for image in venue.images {
            venueDTO.images.append(image.url)
        }
        
        return venueDTO
    }
}

