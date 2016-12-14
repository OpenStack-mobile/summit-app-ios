//
//  Summit.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 5/31/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import struct SwiftFoundation.Date

public struct Summit: Named, Equatable {
    
    public let identifier: Identifier
    
    public var name: String
    
    public var timeZone: String
    
    public var start: Date
    
    public var end: Date
    
    /// Default start date for the Summit.
    public var defaultStart: Date?
    
    public var active: Bool
    
    public var sponsors: Set<Company>
    
    public var speakers: Set<Speaker>
    
    public var startShowingVenues: Date?
    
    public var ticketTypes: Set<TicketType>
    
    // Venue and Venue Rooms
    public var locations: Set<Location>
        
    public var tracks: Set<Track>
    
    public var trackGroups: Set<TrackGroup>
    
    public var eventTypes: Set<EventType>
    
    public var schedule: Set<Event>
    
    public var webpageURL: String
}

// MARK: - Equatable

public func == (lhs: Summit, rhs: Summit) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.name == rhs.name
        && lhs.timeZone == rhs.timeZone
        && lhs.start == rhs.start
        && lhs.end == rhs.end
        && lhs.active == rhs.active
        && lhs.sponsors == rhs.sponsors
        && lhs.speakers == rhs.speakers
        && lhs.startShowingVenues == rhs.startShowingVenues
        && lhs.ticketTypes == rhs.ticketTypes
        && lhs.locations == rhs.locations
        && lhs.tracks == rhs.tracks
        && lhs.trackGroups == rhs.trackGroups
        && lhs.eventTypes == rhs.eventTypes
        && lhs.schedule == rhs.schedule
        && lhs.webpageURL == rhs.webpageURL
}
