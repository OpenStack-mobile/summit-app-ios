//
//  RealmSummitEvent.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import RealmSwift
import struct SwiftFoundation.Date

public class RealmSummitEvent: RealmNamed {
    
    public dynamic var end = NSDate(timeIntervalSince1970: 1)
    public dynamic var start = NSDate(timeIntervalSince1970: 1)
    public dynamic var eventDescription = ""
    public dynamic var allowFeedback = false
    public dynamic var averageFeedback = 0.0
    public dynamic var eventType: RealmEventType!
    public let summitTypes = List<RealmSummitType>()
    public let sponsors = List<RealmCompany>()
    public let tags = List<RealmTag>()
    public dynamic var presentation : RealmPresentation?
    public dynamic var venue : RealmVenue?
    public dynamic var venueRoom : RealmVenueRoom?
}

// MARK: - Fetches

public extension RealmSummitEvent {
    
    static var sortProperties: [RealmSwift.SortDescriptor] {
        
        return [SortDescriptor(property: "start", ascending: true),
                SortDescriptor(property: "end", ascending: true),
                SortDescriptor(property: "name", ascending: true)]
    }
    
    static func search(searchTerm: String, realm: Realm = Store.shared.realm) -> [RealmSummitEvent] {
        
        let realmEntities = realm.objects(RealmSummitEvent).filter("name CONTAINS [c] %@ or ANY presentation.speakers.firstName CONTAINS [c] %@ or ANY presentation.speakers.lastName CONTAINS [c] %@ or presentation.level CONTAINS [c] %@ or ANY tags.name CONTAINS [c] %@ or eventType.name CONTAINS [c] %@", searchTerm, searchTerm, searchTerm, searchTerm, searchTerm, searchTerm).sorted(self.sortProperties)
        
        return realmEntities.map { $0 }
    }
    
    static func filter(startDate: NSDate, endDate: NSDate, eventTypes: [Int]?, summitTypes: [Int]?, tracks: [Int]?, trackGroups: [Int]?, tags: [String]?, levels: [String]?, realm: Realm = Store.shared.realm) -> [RealmSummitEvent] {
        
        var events = realm.objects(RealmSummitEvent).filter("start >= %@ and end <= %@", startDate, endDate).sorted(RealmSummitEvent.sortProperties)
        
        if (eventTypes != nil && eventTypes!.count > 0) {
            events = events.filter("eventType.id in %@", eventTypes!)
        }
        
        if (trackGroups != nil && trackGroups!.count > 0) {
            var trackGroupsFilter = ""
            var separator = ""
            for trackGroup in trackGroups! {
                trackGroupsFilter += "\(separator)ANY presentation.track.trackGroups.id = \(trackGroup)"
                separator = " OR "
            }
            events = events.filter(trackGroupsFilter)
        }
        
        if (tracks != nil && tracks!.count > 0) {
            events = events.filter("presentation.track.id in %@", tracks!)
        }
        
        if (levels != nil && levels!.count > 0) {
            events = events.filter("presentation.level in %@", levels!)
        }
        
        if (summitTypes != nil && summitTypes!.count > 0) {
            for summitTypeId in summitTypes! {
                events = events.filter("ANY summitTypes.id = %@", summitTypeId)
            }
        }
        
        if (tags != nil && tags!.count > 0) {
            var tagsFilter = ""
            var separator = ""
            for tag in tags! {
                tagsFilter += "\(separator)ANY tags.name = [c] '\(tag)'"
                separator = " OR "
            }
            events = events.filter(tagsFilter)
        }
        
        return events.map { $0 }
    }
    
    static func speakerPresentations(speaker: Identifier, startDate: NSDate, endDate: NSDate, realm: Realm = Store.shared.realm) -> [RealmSummitEvent] {
        let events = realm.objects(RealmSummitEvent).filter("ANY presentation.speakers.id = %@ && start >= %@ and end <= %@", speaker, startDate, endDate).sorted(self.sortProperties)
        return events.map { $0 }
    }
}

// MARK: - Encoding

extension SummitEvent: RealmDecodable {
    
    public init(realmEntity: RealmSummitEvent) {
        
        self.identifier = realmEntity.id
        self.name = realmEntity.name
        self.start = Date(foundation: realmEntity.start)
        self.end = Date(foundation: realmEntity.end)
        self.descriptionText = String(realm: realmEntity.eventDescription)
        self.allowFeedback = realmEntity.allowFeedback
        self.type = realmEntity.eventType.id
        self.summitTypes = realmEntity.summitTypes.identifiers
        self.sponsors = realmEntity.sponsors.identifiers
        self.tags = Tag.from(realm: realmEntity.tags)
        self.presentation = Presentation(realmEntity: realmEntity.presentation!)
        
        if realmEntity.averageFeedback == 0.0 {
            
            self.averageFeedback = nil
            
        } else {
            
            self.averageFeedback = realmEntity.averageFeedback
        }
        
        // location
        if let venue = realmEntity.venue?.id {
            
            self.location = venue
            
        } else if let room = realmEntity.venueRoom?.id {
            
            self.location = room
            
        } else {
            
            fatalError("Missing location identifier: \(realmEntity)")
        }
    }
}

extension SummitEvent: RealmEncodable {
    
    public func save(realm: Realm) -> RealmSummitEvent {
        
        let realmEntity = RealmType.cached(identifier, realm: realm)
        
        realmEntity.name = name
        realmEntity.start = start.toFoundation()
        realmEntity.end = end.toFoundation()
        realmEntity.eventDescription = descriptionText ?? ""
        realmEntity.allowFeedback = allowFeedback
        realmEntity.averageFeedback = averageFeedback ?? 0.0
        
        // relationships
        realmEntity.eventType = RealmEventType.cached(type, realm: realm)
        realmEntity.summitTypes.replace(with: summitTypes)
        realmEntity.sponsors.replace(with: sponsors)
        realmEntity.tags.replace(with: tags)
        realmEntity.presentation = presentation.save(realm)
        
        // location
        if let cachedRoom = RealmVenueRoom.find(location, realm: realm) {
            
            realmEntity.venueRoom = cachedRoom
            realmEntity.venue = nil
            
        } else if let cachedVenue = RealmVenue.find(location, realm: realm) {
            
            realmEntity.venue = cachedVenue
            realmEntity.venueRoom = nil
            
        } else {
            
            realmEntity.venue = nil
            realmEntity.venueRoom = nil
        }
        
        return realmEntity
    }
}

