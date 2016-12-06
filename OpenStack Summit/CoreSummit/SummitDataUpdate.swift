//
//  SummitDataUpdate.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/16/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import struct SwiftFoundation.Date

public extension Summit {
    
    typealias DataUpdate = SummitDataUpdate
}

/// The `DataUpdate` version of a `Summit`.
public struct SummitDataUpdate: Named {
    
    public let identifier: Identifier
    
    public var name: String
    
    public var timeZone: String // should be `TimeZone` but would require Realm Schema migration
    
    public var start: Date
    
    public var end: Date
    
    public var active: Bool
    
    public var startShowingVenues: Date?
    
    public var ticketTypes: Set<TicketType>
    
    // Venue and Venue Rooms
    public var locations: Set<Location>
            
    public var webpageURL: String
}

public func == (lhs: Summit.DataUpdate, rhs: Summit.DataUpdate) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.name == rhs.name
        && lhs.timeZone == rhs.timeZone
        && lhs.start == rhs.start
        && lhs.end == rhs.end
        && lhs.active == rhs.active
        && lhs.startShowingVenues == rhs.startShowingVenues
        && lhs.ticketTypes == rhs.ticketTypes
        && lhs.locations == rhs.locations
        && lhs.webpageURL == rhs.webpageURL
}
