//
//  VenueDeserializer.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/16/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON

public class VenueDeserializer: NSObject, DeserializerProtocol {

    var deserializerStorage: DeserializerStorage!
    var deserializerFactory: DeserializerFactory!
    
    public func deserialize(json: JSON) -> BaseEntity {
        let venue : Venue
        
        if let venueId = json.int {
            venue = deserializerStorage.get(venueId)
        }
        else {
            var deserializer = deserializerFactory.create(DeserializerFactories.SummitLocation)
            let summitLocation = deserializer.deserialize(json) as! SummitLocation
            venue = Venue()
            venue.id = json["id"].intValue
            venue.locationDescription = summitLocation.locationDescription
            venue.lat = json["lat"].stringValue
            venue.long = json["long"].stringValue
            venue.long = json["address"].stringValue
            
            var venueRoom: VenueRoom
            deserializer = deserializerFactory.create(DeserializerFactories.VenueRoom)
            for (_, venueRoomJSON) in json["rooms"] {
                venueRoom = deserializer.deserialize(venueRoomJSON) as! VenueRoom
                venue.venueRooms.append(venueRoom)
                
                deserializerStorage.add(venueRoom)
            }
            
            deserializerStorage.add(venue)
        }
        
        return venue
    }
}
