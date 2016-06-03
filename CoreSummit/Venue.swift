//
//  Venue.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public struct Venue: LocationProtocol {
    
    public let identifier: Identifier
    
    public var name: String
    
    public var descriptionText: String?
    
    public var locationType: LocationType
    
    public var country: String
    
    public var address: String?
    
    public var city: String?
    
    public var zipCode: String?
    
    public var state: String?
        
    public var latitude: String?
    
    public var longitude: String?
    
    public var maps: [Image]
    
    public var images: [Image]
}

// MARK: - Supporting Types

public extension Venue {
    
    public enum LocationType: String {
        
        case Internal, External
    }
}