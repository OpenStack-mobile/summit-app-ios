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
    func getVenues()->[VenueListItemDTO]
}

public class VenueListInteractor: NSObject, IVenueListInteractor {
    var genericDataStore: GenericDataStore!
    var venueListItemDTOAssembler: IVenueListItemDTOAssembler!
    
    public func getVenues()->[VenueListItemDTO] {
        let venues:[Venue] = genericDataStore.getAllLocal()
        var venueListItemDTO: VenueListItemDTO
        var dtos: [VenueListItemDTO] = []
        for venue in venues {
            venueListItemDTO = venueListItemDTOAssembler.createDTO(venue)
            dtos.append(venueListItemDTO)
        }
        return dtos
    }
}
