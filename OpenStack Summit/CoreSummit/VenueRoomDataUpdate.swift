//
//  VenueRoomDataUpdate.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 10/24/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public extension VenueRoom {
    
    typealias DataUpdate = VenueRoomDataUpdate
}

public struct VenueRoomDataUpdate: LocationProtocol {
    
    public let identifier: Identifier
    
    public var name: String
    
    public var descriptionText: String?
    
    public var capacity: Int?
    
    public var venue: Identifier
    
    public var floor: VenueFloor?
}

// MARK: - Equatable

public func == (lhs: VenueRoomDataUpdate, rhs: VenueRoomDataUpdate) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.name == rhs.name
        && lhs.descriptionText == rhs.descriptionText
        && lhs.capacity == rhs.capacity
        && lhs.venue == rhs.venue
        && lhs.floor == rhs.floor
}
