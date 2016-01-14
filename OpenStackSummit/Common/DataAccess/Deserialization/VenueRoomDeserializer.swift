//
//  RoomDeserializer.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/16/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON

public class VenueRoomDeserializer: NSObject, IDeserializer {
    var deserializerFactory: DeserializerFactory!
    var deserializerStorage: DeserializerStorage!
    
    public func deserialize(json: JSON) throws -> BaseEntity {
        let venueRoom : VenueRoom
        
        if let venueRoomId = json.int {
            guard let check: VenueRoom = deserializerStorage.get(venueRoomId) else {
                throw DeserializerError.EntityNotFound("Venue room with id \(venueRoomId) not found on deserializer storage")
            }
            venueRoom = check
        }
        else {
            try validateRequiredFields(["id", "name"], inJson: json)
            
            let deserializer = deserializerFactory.create(DeserializerFactoryType.Location)
            let location = try deserializer.deserialize(json) as! Location
            venueRoom = VenueRoom()
            venueRoom.id = json["id"].intValue
            venueRoom.capacity = json["Capacity"].intValue
            venueRoom.name = location.name
            venueRoom.locationDescription = location.locationDescription
            
            if(!deserializerStorage.exist(venueRoom)) {
                deserializerStorage.add(venueRoom)
            }
        }
        
        return venueRoom
    }
}
