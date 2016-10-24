//
//  VenueRoomDataUpdateJSON.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 10/24/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

public extension VenueRoomDataUpdate {
    
    typealias JSONKey = VenueRoom.JSONKey
}

extension VenueRoomDataUpdate: JSONDecodable {
    
    public init?(JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let classNameString = JSONObject[LocationJSONKey.class_name.rawValue]?.rawValue as? String,
            let identifier = JSONObject[LocationJSONKey.id.rawValue]?.rawValue as? Int,
            let name = JSONObject[LocationJSONKey.name.rawValue]?.rawValue as? String,
            let venueIdentifier = JSONObject[JSONKey.venue_id.rawValue]?.rawValue as? Int,
            let floorJSON = JSONObject[JSONKey.floor.rawValue],
            let floor = VenueFloor(JSONValue: floorJSON)
            where classNameString == VenueRoom.JSONClassName
            else { return nil }
        
        self.identifier = identifier
        self.name = name
        self.venue = venueIdentifier
        self.floor = floor
        
        // optional
        self.descriptionText = JSONObject[LocationJSONKey.description.rawValue]?.rawValue as? String
        self.capacity = JSONObject[JSONKey.Capacity.rawValue]?.rawValue as? Int
    }
}