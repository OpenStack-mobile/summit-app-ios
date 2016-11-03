//
//  VenueFloorJSON.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 10/4/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

public extension VenueFloor {
    
    enum JSONKey: String {
        
        case id, name, description, number, image, venue_id, rooms
    }
}

extension VenueFloor: JSONDecodable {
    
    public init?(JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.rawValue as? Int,
            let name = JSONObject[JSONKey.name.rawValue]?.rawValue as? String,
            let number = JSONObject[JSONKey.number.rawValue]?.rawValue as? Int,
            let venueIdentifier = JSONObject[JSONKey.venue_id.rawValue]?.rawValue as? Int
            else { return nil }
        
        self.identifier = identifier
        self.name = name
        self.number = number
        self.venue = venueIdentifier
        
        // optional
        self.imageURL = JSONObject[JSONKey.image.rawValue]?.rawValue as? String
        
        if let roomsJSONArray = JSONObject[JSONKey.rooms.rawValue]?.arrayValue {
            
            guard let rooms = Int.fromJSON(roomsJSONArray)
                else { return nil }
            
            self.rooms = Set(rooms)
            
        } else {
            
            self.rooms = []
        }
        
        self.descriptionText = JSONObject[JSONKey.description.rawValue]?.rawValue as? String
    }
}