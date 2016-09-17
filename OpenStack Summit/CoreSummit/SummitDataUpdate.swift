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
    
    public var startShowingVenues: Date?
    
    public var summitTypes: [SummitType]
    
    public var ticketTypes: [TicketType]
    
    // Venue and Venue Rooms
    public var locations: [Location]
            
    public var webpageURL: String
}
