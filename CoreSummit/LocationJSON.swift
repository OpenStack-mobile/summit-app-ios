//
//  LocationJSON.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation

import SwiftFoundation

public enum LocationJSONKey: String {
    
    case id, name, description, class_name
}

extension Summit.Locations: JSONDecodable {
    
    public init?(JSONValue: JSON.Value) {
        
        guard let JSONArray = JSONValue.arrayValue
            else { return nil }
        
        if let venues = Venue.fromJSON(JSONArray) {
            
            self = .venues(venues)
            return
        }
        
        if let rooms = VenueRoom.fromJSON(JSONArray) {
            
            self = .rooms(rooms)
            return
        }
        
        return nil
    }
}