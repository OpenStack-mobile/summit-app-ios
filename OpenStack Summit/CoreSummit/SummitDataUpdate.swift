//
//  SummitDataUpdate.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/16/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import struct Foundation.Date

public extension Summit {
    
    /// The `DataUpdate` version of a `Summit`.
    public struct DataUpdate: Named {
        
        public let identifier: Identifier
        
        public let name: String
        
        public let timeZone: String // should be `TimeZone` but would require Realm Schema migration
        
        public let datesLabel: String?
        
        public let start: Date
        
        public let end: Date
        
        public let active: Bool
        
        public let startShowingVenues: Date?
        
        public let ticketTypes: Set<TicketType>
        
        // Venue and Venue Rooms
        public let locations: Set<Location>
        
        public let webpageURL: String
    }
}

// MARK: - Equatable

public func == (lhs: Summit.DataUpdate, rhs: Summit.DataUpdate) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.name == rhs.name
        && lhs.timeZone == rhs.timeZone
        && lhs.datesLabel == rhs.datesLabel
        && lhs.start == rhs.start
        && lhs.end == rhs.end
        && lhs.active == rhs.active
        && lhs.startShowingVenues == rhs.startShowingVenues
        && lhs.ticketTypes == rhs.ticketTypes
        && lhs.locations == rhs.locations
        && lhs.webpageURL == rhs.webpageURL
}
