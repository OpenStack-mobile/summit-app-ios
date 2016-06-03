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

public enum Location {
    
    case venue(Venue)
    case room(VenueRoom)
}