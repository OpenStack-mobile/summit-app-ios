//
//  VenueRoomJSON.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

public extension VenueRoom {
    
    static var JSONClassName: String { return "SummitVenueRoom" }
    
    enum JSONKey: String {
        
        case Capacity, venue_id, floor_id
    }
}

extension VenueRoom: JSONDecodable {
    
    public init?(JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let classNameString = JSONObject[LocationJSONKey.class_name.rawValue]?.rawValue as? String,
            let identifier = JSONObject[LocationJSONKey.id.rawValue]?.rawValue as? Int,
            let name = JSONObject[LocationJSONKey.name.rawValue]?.rawValue as? String,
            let venueIdentifier = JSONObject[JSONKey.venue_id.rawValue]?.rawValue as? Int,
            let floorIdentifier = JSONObject[JSONKey.floor_id.rawValue]?.rawValue as? Int
            where classNameString == VenueRoom.JSONClassName
            else { return nil }
        
        self.identifier = identifier
        self.name = name
        self.venue = venueIdentifier
        self.floor = floorIdentifier
        
        // optional
        self.descriptionText = JSONObject[LocationJSONKey.description.rawValue]?.rawValue as? String
        self.capacity = JSONObject[JSONKey.Capacity.rawValue]?.rawValue as? Int
    }
}