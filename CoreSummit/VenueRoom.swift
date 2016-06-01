//
//  VenueRoom.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public struct VenueRoom: Location {
    
    public let identifier: Identifier
    
    public var name: String
    
    public var descriptionText: String
    
    public var capacity: Int
    
    public var venueIdentifier: Identifier
}