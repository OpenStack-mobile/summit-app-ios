//
//  VenueDeserializer.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/16/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON

public class VenueDeserializer: NSObject, IDeserializer {

    var deserializerStorage: DeserializerStorage!
    var deserializerFactory: DeserializerFactory!
    
    public init(deserializerStorage: DeserializerStorage, deserializerFactory: DeserializerFactory) {
        self.deserializerStorage = deserializerStorage
        self.deserializerFactory = deserializerFactory
    }
    
    public override init() {
        super.init()
    }
    
    public func deserialize(json: JSON) throws -> RealmEntity {
        let venue : Venue
        
        if let venueId = json.int {
            guard let check: Venue = deserializerStorage.get(venueId) else {
                throw DeserializerError.EntityNotFound("Venue with id \(venueId) not found on deserializer storage")
            }
            venue = check
        }
        else {
            try validateRequiredFields(["id"], inJson: json)

            var deserializer = deserializerFactory.create(DeserializerFactoryType.Location)
            let location = try deserializer.deserialize(json) as! Location
            venue = Venue()
            venue.id = json["id"].intValue
            venue.name = location.name
            venue.locationDescription = location.locationDescription
            venue.lat = json["lat"].string ?? ""
            venue.long = json["lng"].string ?? ""
            venue.address = json["address_1"].string ?? ""
            venue.city = json["city"].string ?? ""
            venue.state = json["state"].string ?? ""
            venue.zipCode = json["zip_code"].string ?? ""
            venue.country = json["country"].string ?? ""
            venue.isInternal = (json["location_type"].string ?? "") == "Internal"
            
            var image: Image
            deserializer = deserializerFactory.create(DeserializerFactoryType.Image)
            for (_, imageJSON) in json["images"] {
                image = try deserializer.deserialize(imageJSON) as! Image
                if !image.url.isEmpty {
                    venue.images.append(image)
                }
            }
            for (_, mapJSON) in json["maps"] {
                image = try deserializer.deserialize(mapJSON) as! Image
                if !image.url.isEmpty {
                    venue.maps.append(image)
                }
            }
                        
            deserializerStorage.add(venue)
        }
        
        return venue
    }
}
