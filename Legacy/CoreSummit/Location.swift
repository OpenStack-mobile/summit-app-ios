//
//  Location.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public protocol LocationProtocol: Named {
    
    var descriptionText: String? { get }
}

public enum Location {
    
    case venue(Venue)
    case room(VenueRoom)
    
    public var rawValue: LocationProtocol {
        
        switch self {
        case let .venue(venue): return venue
        case let .room(room): return room
        }
    }
}