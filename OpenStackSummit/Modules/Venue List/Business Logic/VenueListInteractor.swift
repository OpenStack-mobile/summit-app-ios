//
//  VenueListInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/4/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IVenueListInteractor {
    func getInternalVenues() -> [VenueListItemDTO]
    func getExternalVenues() -> [VenueListItemDTO]
}

public class VenueListInteractor: NSObject, IVenueListInteractor {
    var genericDataStore: GenericDataStore!
    var venueListItemDTOAssembler: IVenueListItemDTOAssembler!
    
    public func getInternalVenues() -> [VenueListItemDTO] {
        let venues:[Venue] = genericDataStore.getAllLocal()
        var venueListItemDTO: VenueListItemDTO
        var dtos: [VenueListItemDTO] = []
        for venue in venues {
            if venue.isInternal {
                venueListItemDTO = venueListItemDTOAssembler.createDTO(venue)
                dtos.append(venueListItemDTO)
            }
        }
        return dtos
    }
    
    public func getExternalVenues() -> [VenueListItemDTO] {
        let venues:[Venue] = genericDataStore.getAllLocal()
        var venueListItemDTO: VenueListItemDTO
        var dtos: [VenueListItemDTO] = []
        for venue in venues {
            if !venue.isInternal {
                venueListItemDTO = venueListItemDTOAssembler.createDTO(venue)
                dtos.append(venueListItemDTO)
            }
        }
        return dtos
    }
}
