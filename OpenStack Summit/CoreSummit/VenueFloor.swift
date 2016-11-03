//
//  VenueFloor.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 10/4/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public struct VenueFloor: Named, Equatable {
    
    public let identifier: Identifier
    
    public var name: String
    
    public var descriptionText: String?
    
    public var number: Int
    
    public var imageURL: String?
    
    public var venue: Identifier
    
    public var rooms: Set<Identifier>
}

// MARK: - Equatable

public func == (lhs: VenueFloor, rhs: VenueFloor) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.name == rhs.name
        && lhs.descriptionText == rhs.descriptionText
        && lhs.number == rhs.number
        && lhs.imageURL == rhs.imageURL
        && lhs.venue == rhs.venue
        && lhs.rooms == rhs.rooms
}
