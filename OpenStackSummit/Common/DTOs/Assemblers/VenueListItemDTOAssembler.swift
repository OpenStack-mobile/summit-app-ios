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
    func getAddress(venue: Venue) -> String
}

public class VenueListItemDTOAssembler: NamedDTOAssembler, IVenueListItemDTOAssembler {
    
    public func createDTO(venue: Venue) -> VenueListItemDTO {
        let venueListItemDTO: VenueListItemDTO = super.createDTO(venue)
        
        venueListItemDTO.address = getAddress(venue)
        venueListItemDTO.lat = Double(venue.lat)
        venueListItemDTO.long = Double(venue.long)
        
        if venue.images.count > 0 {
            venueListItemDTO.backgroundImageUrl = venue.images[0].url
        }
        
        return venueListItemDTO
    }
    
    public func getAddress(venue: Venue) -> String {
        var fullAddress = venue.address
        
        var separator = fullAddress.isEmpty ? "" : ", "
        if (!venue.city.isEmpty) {
            fullAddress += "\(separator)\(venue.city)"
            separator = fullAddress.isEmpty ? "" : " "
        }
        
        if (!venue.state.isEmpty) {
            fullAddress += "\(separator)\(venue.state)"
            separator = fullAddress.isEmpty ? "" : " "
        }
        
        if (!venue.zipCode.isEmpty) {
            fullAddress += "\(separator)(\(venue.zipCode))"
            separator = fullAddress.isEmpty ? "" : ", "
        }
        
        if (!venue.country.isEmpty) {
            fullAddress += "\(separator)\(venue.country)"
        }
        
        return fullAddress
    }
}

