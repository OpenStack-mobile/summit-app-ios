//
//  Location.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public protocol LocationProtocol: Named, Equatable {
    
    var descriptionText: String? { get }
}

public enum Location: Unique, Equatable {
    
    case venue(Venue)
    case room(VenueRoom)
    
    public var rawValue: LocationProtocol {
        
        switch self {
        case let .venue(venue): return venue
        case let .room(room): return room
        }
    }
    
    public var identifier: Identifier {
        
        return rawValue.identifier
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
