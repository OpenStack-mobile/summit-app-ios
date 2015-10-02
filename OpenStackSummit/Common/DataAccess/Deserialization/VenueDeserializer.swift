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
    
    public func deserialize(json: JSON) throws -> BaseEntity {
        let venue : Venue
        
        if let venueId = json.int {
            venue = deserializerStorage.get(venueId)
        }
        else {
            var deserializer = deserializerFactory.create(DeserializerFactoryType.Location)
            let location = try deserializer.deserialize(json) as! Location
            venue = Venue()
            venue.id = json["id"].intValue
            venue.name = location.name
            venue.locationDescription = location.locationDescription
            venue.lat = json["lat"].stringValue
            venue.long = json["long"].stringValue
            venue.address = json["address_1"].stringValue

            var map: Image
            deserializer = deserializerFactory.create(DeserializerFactoryType.Image)
            for (_, mapJSON) in json["maps"] {
                map = try deserializer.deserialize(mapJSON) as! Image
                venue.maps.append(map)
            }
            
            var venueRoom: VenueRoom
            deserializer = deserializerFactory.create(DeserializerFactoryType.VenueRoom)
            for (_, venueRoomJSON) in json["rooms"] {
                venueRoom = try deserializer.deserialize(venueRoomJSON) as! VenueRoom
                venue.venueRooms.append(venueRoom)
            }
            
            deserializerStorage.add(venue)
        }
        
        return venue
    }
}
