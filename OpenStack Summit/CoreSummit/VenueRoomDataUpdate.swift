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

