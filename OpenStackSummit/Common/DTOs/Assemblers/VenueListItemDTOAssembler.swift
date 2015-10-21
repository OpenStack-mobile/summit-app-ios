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
        
        let venueListItemDTO: VenueListItemDTO = super.createDTO(venue)
        venueListItemDTO.address = fullAddress
        venueListItemDTO.lat = Double(venue.lat)
        venueListItemDTO.long = Double(venue.long)
        
        return venueListItemDTO
    }
}

