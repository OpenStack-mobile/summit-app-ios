//
//  SummitVenueImageDataUpdateStrategy.swift
//  OpenStackSummit
//
//  Created by Claudio on 3/23/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit

public class SummitVenueImageDataUpdateStrategy: DataUpdateStrategy {
    var venueDataStore: VenueDataStore!
    
    public override init() {
        super.init()
    }
    
    public override init(genericDataStore: GenericDataStore) {
        super.init(genericDataStore: genericDataStore)
    }
    
    public override func process(dataUpdate: DataUpdate) throws {
        if let venueId = dataUpdate.originalJSON["entity"]["location_id"].int {
            if let venue: Venue = genericDataStore.getByIdLocal(venueId) {
                if let image = dataUpdate.entity as? Image {
                    switch dataUpdate.operation {
                    case .Insert:
                        if (dataUpdate.className == "SummitLocationImage") {
                            try venueDataStore.addImage(image, toVenue: venue)
                        }
                        if (dataUpdate.className == "SummitLocationMap") {
                            try venueDataStore.addMap(image, toVenue: venue)
                        }
                    case .Update:
                        genericDataStore.saveOrUpdateLocal(dataUpdate.entity, completionBlock: nil)
                    case .Delete:
                        if (dataUpdate.className == "SummitLocationImage") {
                            try venueDataStore.removeImage(image, fromVenue: venue)
                        }
                        if (dataUpdate.className == "SummitLocationMap") {
                            try venueDataStore.removeMap(image, fromVenue: venue)
                        }
                    default:
                        break
                    }
                }
                else {
                    throw DataUpdateError.InvalidOperationError("Entity is not an image")
                }
            }
            else {
                throw DataUpdateError.InvalidOperationError("Venue with id \(venueId) not found")
            }
        }
        else {
            throw DataUpdateError.InvalidOperationError("It wasn't possible to find location_id on data update json")
        }
    }
}
