//
//  Venue.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public struct Venue: Location {
    
    public let identifier: Identifier
    
    public var name: String
    
    public var descriptionText: String
    
    public var address: String
    
    public var city: String
    
    public var zipCode: String
    
    public var state: String
    
    public var country: String
    
    public var latitude: String
    
    public var longitude: String
    
    public var isInternal: Bool
    
    public var maps: [Image]
    
    public var images: [Image]
}