//
//  VenueDetailInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/4/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IVenueDetailInteractor {
    func getVenue(venueId: Int) -> VenueDTO
}

public class VenueDetailInteractor: NSObject, IVenueDetailInteractor {
    var venueDataStore: IVenueDataStore!
    var venueDTOAssembler: IVenueDTOAssembler!
    
    public func getVenue(venueId: Int) -> VenueDTO {
        let venue: Venue? = venueDataStore.getByIdLocal(venueId)
        let venueDTO = venueDTOAssembler.createDTO(venue!)
        return venueDTO
    }
}
