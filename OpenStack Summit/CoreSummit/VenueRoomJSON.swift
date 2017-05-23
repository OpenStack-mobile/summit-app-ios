//
//  VenueRoomJSON.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import JSON

internal extension VenueRoom {
    
    static var JSONClassName: String { return "SummitVenueRoom" }
    
    enum JSONKey: String {
        
        case Capacity, venue_id, floor_id, floor
    }
}

extension VenueRoom: JSONDecodable {
    
    public init?(json JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let classNameString = JSONObject[LocationJSONKey.class_name.rawValue]?.rawValue as? String,
            classNameString == VenueRoom.JSONClassName,
            let identifier = JSONObject[LocationJSONKey.id.rawValue]?.integerValue,
            let name = JSONObject[LocationJSONKey.name.rawValue]?.rawValue as? String,
            let venueIdentifier = JSONObject[JSONKey.venue_id.rawValue]?.integerValue,
            let floorIdentifier = JSONObject[JSONKey.floor_id.rawValue]?.integerValue
            else { return nil }
        
        self.identifier = identifier
        self.name = name
        self.venue = venueIdentifier
        self.floor = floorIdentifier > 0 ? floorIdentifier : nil
        
        // optional
        self.descriptionText = JSONObject[LocationJSONKey.description.rawValue]?.rawValue as? String
        
        if let capacity = JSONObject[JSONKey.Capacity.rawValue]?.integerValue {
            
            self.capacity = Int(capacity)
            
        } else {
            
            self.capacity = nil
        }
        
    }
}
