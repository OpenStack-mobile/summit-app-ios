//
//  VenueDeserializer.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/16/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON

public class VenueDeserializer: DeserializerProtocol {

    var deserializerStorage = DeserializerStorage()
    var deserializerFactory = DeserializerFactory()
    
    public func deserialize(json: JSON) -> BaseEntity {
        var deserializer = deserializerFactory.create(DeserializerFactories.SummitLocation)
        let venue = Venue()
        venue.id = json["id"].intValue
        venue.summitLocation = deserializer.deserialize(json) as! SummitLocation
        venue.lat = json["lat"].stringValue
        venue.long = json["long"].stringValue
        venue.long = json["address"].stringValue
        
        var venueRoom: VenueRoom
        deserializer = deserializerFactory.create(DeserializerFactories.VenueRoom)
        for (key, venueRoomJSON) in json["rooms"] {
            venueRoom = deserializer.deserialize(venueRoomJSON) as! VenueRoom
            if(!self.deserializerStorage.exist(venueRoom)) {
                venue.venueRooms.append(venueRoom)
            }
            
            deserializerStorage.add(venueRoom)
        }
        
        return venue
    }
}
