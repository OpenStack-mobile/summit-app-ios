//
//  Summit.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 5/31/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import struct SwiftFoundation.Date

public struct Summit: Named {
    
    public let identifier: Identifier
    
    public var name: String
    
    public var timeZone: String // should be `TimeZone` but would require Realm Schema migration
    
    public var start: Date
    
    public var end: Date
    
    //public var timestamp: Date
    
    //public var active: Bool
    
    public var sponsors: [Company]
    
    public var speakers: [PresentationSpeaker]
    
    public var startShowingVenues: Date?
        
    public var summitTypes: [SummitType]
        
    public var ticketTypes: [TicketType]
    
    // Venue and Venue Rooms
    public var locations: [Location]
        
    public var tracks: [Track]
    
    public var trackGroups: [TrackGroup]
    
    public var eventTypes: [EventType]
    
    public var schedule: [Event]
    
    public var webpageURL: String
}
