//
//  VenueListItemDTOAssembler.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/16/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IVenueListItemDTOAssembler {
    func createDTO(venue: Venue) -> VenueListItemDTO
}

public class VenueListItemDTOAssembler: NamedDTOAssembler, IVenueListItemDTOAssembler {
    
    public func createDTO(venue: Venue) -> VenueListItemDTO {
        let venueListItemDTO: VenueListItemDTO = super.createDTO(venue)
        venueListItemDTO.lat = Double(venue.lat)
        venueListItemDTO.long = Double(venue.long)
        
        return venueListItemDTO
    }
}

