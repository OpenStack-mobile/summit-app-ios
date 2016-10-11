//
//  VenueFloor.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 10/4/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public struct VenueFloor: Named {
    
    public let identifier: Identifier
    
    public var name: String
    
    public var descriptionText: String?
    
    public var number: Int
    
    public var imageURL: String?
    
    public var venue: Identifier
    
    public var rooms: [Identifier]
}