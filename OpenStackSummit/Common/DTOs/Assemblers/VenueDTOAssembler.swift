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

public class VenueDTOAssembler: NamedDTOAssembler, IVenueDTOAssembler {
    public override init() {
        super.init()
    }

    public init(venueRoomDTOAssembler: VenueRoomDTOAssembler) {
        self.venueRoomDTOAssembler = venueRoomDTOAssembler
    }
    
    var venueRoomDTOAssembler: IVenueRoomDTOAssembler!
    var venueListItemDTOAssembler = VenueListItemDTOAssembler()
    
    public func createDTO(venue: Venue) -> VenueDTO {
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
        
        var venueRoomDTO: VenueRoomDTO
        for venueRoom in venue.venueRooms {
            venueRoomDTO = venueRoomDTOAssembler.createDTO(venueRoom)
            venueDTO.rooms.append(venueRoomDTO)
        }
        return venueDTO
    }
    
    public func getAddress(venue: Venue) -> String {
        var fullAddress = venue.address
        
        var separator = ", "
        if (!venue.city.isEmpty) {
            fullAddress += "\(separator)\(venue.city)"
            separator = " "
        }
        
        if (!venue.state.isEmpty) {
            fullAddress += "\(separator)\(venue.state)"
            separator = " "
        }
        
        if (!venue.zipCode.isEmpty) {
            fullAddress += "\(separator)(\(venue.zipCode))"
            separator = " "
        }
        
        if (!venue.country.isEmpty) {
            fullAddress += ", \(venue.country)"
        }
        
        return fullAddress
    }
}

