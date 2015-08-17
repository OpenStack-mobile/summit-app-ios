//
//  RoomDeserializer.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/16/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON

public class VenueRoomDeserializer: DeserializerProtocol {
    var deserializerFactory = DeserializerFactory()
    
    public func deserialize(json: JSON) -> BaseEntity {
        let deserializer = deserializerFactory.create(DeserializerFactories.SummitLocation)
        let venueRoom = VenueRoom()
        venueRoom.id = json["id"].intValue
        venueRoom.capacity = json["capacity"].intValue
        venueRoom.summitLocation = deserializer.deserialize(json) as! VenueRoom
        return venueRoom
    }
}
