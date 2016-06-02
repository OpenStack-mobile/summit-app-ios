//
//  RealmSummit.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 5/31/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation
import RealmSwift

public class RealmSummit: RealmNamed {
    public dynamic var startDate = NSDate(timeIntervalSince1970: 1)
    public dynamic var endDate = NSDate(timeIntervalSince1970: 1)
    public dynamic var timeZone = ""
    public dynamic var initialDataLoadDate = NSDate(timeIntervalSince1970: 1)
    public dynamic var startShowingVenuesDate = NSDate(timeIntervalSince1970: 1)
    public let types = List<RealmSummitType>()
    public let ticketTypes = List<RealmTicketType>()
    public let venues = List<RealmVenue>()
    public let venuesRooms = List<RealmVenueRoom>()
    public let events = List<RealmSummitEvent>()
    public let track = List<RealmTrack>()
    public let trackGroups = List<RealmTrackGroup>()
    public let eventTypes = List<RealmEventType>()
}

// MARK: - Realm Encoding

extension Summit: RealmEncodable {
    
    public init(realmEntity: RealmSummit) {
        
        self.identifier = realmEntity.id
        self.name = realmEntity.name
        self.start = Date(foundation: realmEntity.startDate)
        self.end = Date(foundation: realmEntity.endDate)
        self.timeZone = realmEntity.timeZone
        
        // relationships
        self.summitTypes = SummitType.from(realm: realmEntity.types)
        self.ticketTypes = TicketType.from(realm: realmEntity.ticketTypes)
        self.eventTypes = EventType.from(realm: realmEntity.eventTypes)
        self.tracks = Track.from(realm: realmEntity.track)
        self.trackGroups = TrackGroup.from(realm: realmEntity.trackGroups)
        self.schedule = Event.from(realm: realmEntity.events)
        
        // locations
        /*
        if realmEntity.venues.isEmpty == false {
            
            self.locations = .venues(Venue.from(realm: realmEntity.venues))
            
        } else if realmEntity.venuesRooms.isEmpty == false {
            
            self.locations = .rooms(VenueRoom.from(realm: realmEntity.venues))
            
        } else {
            
            self.locations = .none
        }*/
        
        // optional values
        if realmEntity.startShowingVenuesDate != NSDate(timeIntervalSince1970: 1) {
            
            self.startShowingVenues = Date(foundation: realmEntity.startShowingVenuesDate)
            
        } else {
            
            self.startShowingVenues = nil
        }
    }
}

/*
extension Summit: RealmDecodable {
    
    public func save(realm: Realm) throws -> RealmSummit {
        
        
    }
}*/