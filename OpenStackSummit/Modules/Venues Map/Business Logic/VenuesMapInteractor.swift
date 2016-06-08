//
//  VenuesMapInteractor.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 3/9/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit
import CoreSummit

public protocol VenuesMapInteractorProtocol {
    
    func getInternalVenuesWithCoordinates() -> [VenueListItem]
}

public final class VenuesMapInteractor: VenuesMapInteractorProtocol {
    
    var genericDataStore = GenericDataStore()
    
    public func getInternalVenuesWithCoordinates() -> [VenueListItem] {
        
        let venues: [RealmVenue] = genericDataStore.getAllLocal()
        
        let filteredVenues = venues.filter { $0.isInternal && $0.lat.isEmpty && $0.long.isEmpty }
        
        return VenueListItem.from(realm: filteredVenues)
    }
}
