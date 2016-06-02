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
    
    public var startShowingVenues: Date?
        
    public var summitTypes: [SummitType]
    
    public var sponsors: [Company]
    
    public var ticketTypes: [TicketType]
    
    // Venue and Venue Rooms
    public var locations: Locations
    
    public var speakers: [PresentationSpeaker]
    
    public var tracks: [Track]
    
    public var trackGroups: [TrackGroup]
    
    public var eventTypes: [EventType]
    
    public var schedule: [SummitEvent]
}

// MARK: - Supporting Types

public extension Summit {
    
    public enum Locations {
        
        case none
        case venues([Venue])
        case rooms([VenueRoom])
        
        public init?(rawValue: [Location]) {
            
            guard rawValue.isEmpty == false
                else { self = .none; return }
            
            if let venues = rawValue as? [Venue] {
                
                self = .venues(venues)
                return
            }
            
            if let rooms = rawValue as? [VenueRoom] {
                
                self = .rooms(rooms)
                return
            }
            
            return nil
        }
        
        /*
        public var rawValue: [Location] {
            
            switch self {
            case let .venues(values): return values as! [Location]
            case let .rooms(values): return values as! [Location]
            }
        }*/
    }
}


