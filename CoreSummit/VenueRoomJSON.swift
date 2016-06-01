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
        
        case Capacity, venue_id
    }
}

extension VenueRoom: JSONDecodable {
    
    public init?(JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[LocationJSONKey.id.rawValue]?.rawValue as? Int,
            let name = JSONObject[LocationJSONKey.name.rawValue]?.rawValue as? String,
            let description = JSONObject[LocationJSONKey.description.rawValue]?.rawValue as? String,
            let capacity = JSONObject[JSONKey.Capacity.rawValue]?.rawValue as? Int,
            let venueIdentifier = JSONObject[JSONKey.venue_id.rawValue]?.rawValue as? Int
            else { return nil }
        
        self.identifier = identifier
        self.name = name
        self.descriptionText = description
        self.capacity = capacity
        self.venueIdentifier = venueIdentifier
    }
}