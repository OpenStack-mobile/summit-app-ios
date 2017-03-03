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

public enum Location: Unique {
    
    case venue(Venue)
    case room(VenueRoom)
    
    public var rawValue: Any {
        
        switch self {
        case let .venue(venue): return venue
        case let .room(room): return room
        }
    }
    
    public var identifier: Identifier {
        
        switch self {
        case let .venue(venue): return venue.identifier
        case let .room(room): return room.identifier
        }
    }
    
    public var venue: Identifier {
        
        switch self {
        case let .venue(venue): return venue.identifier
        case let .room(room): return room.venue
        }
    }
}

// MARK: - Equatable

public func == (lhs: Location, rhs: Location) -> Bool {
    
    switch (lhs, rhs) {
    case let (.venue(lhsValue), .venue(rhsValue)): return lhsValue == rhsValue
    case let (.room(lhsValue), .room(rhsValue)): return lhsValue == rhsValue
    default: return false
    }
}
