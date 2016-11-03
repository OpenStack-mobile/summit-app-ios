//
//  VenueRoom.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public struct VenueRoom: LocationProtocol, Equatable {
    
    public let identifier: Identifier
    
    public var name: String
    
    public var descriptionText: String?
    
    public var capacity: Int?
    
    public var venue: Identifier
    
    public var floor: Identifier?
}

// MARK: - Equatable

public func == (lhs: VenueRoom, rhs: VenueRoom) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.name == rhs.name
        && lhs.descriptionText == rhs.descriptionText
        && lhs.capacity == rhs.capacity
        && lhs.venue == rhs.venue
        && lhs.floor == rhs.floor
}