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
    
    public func deserialize(json: JSON) -> BaseEntity {
        let venue : Venue
        
        if let venueId = json.int {
            venue = deserializerStorage.get(venueId)
        }
        else {
            var deserializer = deserializerFactory.create(DeserializerFactories.Location)
            let location = deserializer.deserialize(json) as! Location
            venue = Venue()
            venue.id = json["id"].intValue
            venue.name = location.name
            venue.locationDescription = location.locationDescription
            venue.lat = json["lat"].stringValue
            venue.long = json["long"].stringValue
            venue.address = json["address"].stringValue

            var map: Image
            deserializer = deserializerFactory.create(DeserializerFactories.Image)
            for (_, mapJSON) in json["maps"] {
                map = deserializer.deserialize(mapJSON) as! Image
                venue.maps.append(map)
            }
            
            var venueRoom: VenueRoom
            deserializer = deserializerFactory.create(DeserializerFactories.VenueRoom)
            for (_, venueRoomJSON) in json["rooms"] {
                venueRoom = deserializer.deserialize(venueRoomJSON) as! VenueRoom
                venue.venueRooms.append(venueRoom)
            }
            
            deserializerStorage.add(venue)
        }
        
        return venue
    }
}
