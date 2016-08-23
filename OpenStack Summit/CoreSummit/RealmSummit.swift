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
    public let speakers = List<RealmPresentationSpeaker>()
    public let sponsors = List<RealmCompany>()
}

// MARK: - Realm Encoding

extension Summit: RealmDecodable {
    
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
        self.schedule = SummitEvent.from(realm: realmEntity.events)
        self.speakers = PresentationSpeaker.from(realm: realmEntity.speakers)
        self.sponsors = Company.from(realm: realmEntity.sponsors)
        
        // locations
        let venues = realmEntity.venues.map { Location.venue(Venue(realmEntity: $0)) }
        let rooms = realmEntity.venuesRooms.map { Location.room(VenueRoom(realmEntity: $0)) }
        self.locations = venues + rooms
        
        // optional values
        if realmEntity.startShowingVenuesDate != NSDate(timeIntervalSince1970: 1) {
            
            self.startShowingVenues = Date(foundation: realmEntity.startShowingVenuesDate)
            
        } else {
            
            self.startShowingVenues = nil
        }
    }
}

extension Summit: RealmEncodable {
    
    public func save(realm: Realm) -> RealmSummit {
        
        let realmEntity = RealmType.cached(identifier, realm: realm)
        
        realmEntity.name = name
        realmEntity.startDate = start.toFoundation()
        realmEntity.endDate = end.toFoundation()
        realmEntity.timeZone = timeZone
        realmEntity.startShowingVenuesDate = startShowingVenues?.toFoundation() ?? Date(timeIntervalSince1970: 1).toFoundation()
        
        // relationships
        realmEntity.types.replace(with: summitTypes.save(realm))
        realmEntity.ticketTypes.replace(with: ticketTypes.save(realm))
        realmEntity.eventTypes.replace(with: eventTypes.save(realm))
        realmEntity.track.replace(with: tracks.save(realm))
        realmEntity.trackGroups.replace(with: trackGroups.save(realm))
        realmEntity.speakers.replace(with: speakers)
        realmEntity.sponsors.replace(with: sponsors)
        
        // locations
        realmEntity.venues.removeAll()
        realmEntity.venuesRooms.removeAll()
        for location in locations {
            
            switch location {
            case let .venue(venue): realmEntity.venues.append(venue.save(realm))
            case let .room(room): realmEntity.venuesRooms.append(room.save(realm))
            }
        }
        
        // save schedule after locations, to fault the relationships
        realmEntity.events.replace(with: schedule)
        
        return realmEntity
    }
}
