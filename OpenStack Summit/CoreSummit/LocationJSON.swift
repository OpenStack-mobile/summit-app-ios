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

extension Location: JSONDecodable {
    
    public init?(JSONValue: JSON.Value) {
        
        if let venue = Venue(JSONValue: JSONValue) {
            
            self = .venue(venue)
            
            
        } else if let room = VenueRoom(JSONValue: JSONValue) {
            
            self = .room(room)
            
            
        } else {
            
            return nil
        }
    }
}