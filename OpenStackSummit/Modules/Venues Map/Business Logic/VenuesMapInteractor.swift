//
//  VenuesMapInteractor.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 3/9/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IVenuesMapInteractor {
    func getInternalVenuesWithCoordinates() -> [VenueListItemDTO]
}

public class VenuesMapInteractor: NSObject, IVenuesMapInteractor {
    var genericDataStore: GenericDataStore!
    var venueListItemDTOAssembler: IVenueListItemDTOAssembler!
    
    public func getInternalVenuesWithCoordinates() -> [VenueListItemDTO] {
        let venues:[Venue] = genericDataStore.getAllLocal()
        var venueListItemDTO: VenueListItemDTO
        var dtos: [VenueListItemDTO] = []
        for venue in venues {
            if venue.isInternal && !venue.lat.isEmpty && !venue.long.isEmpty {
                venueListItemDTO = venueListItemDTOAssembler.createDTO(venue)
                dtos.append(venueListItemDTO)
            }
        }
        return dtos
    }
}
