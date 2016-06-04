//
//  RealmSummitEvent.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

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
    
    /*
    public var summit: Summit {
        return try! RealmFactory().create().objects(Summit).first!
    }*/
}

// MARK: - Encoding

extension SummitEvent: RealmDecodable {
    
    public init(realmEntity: RealmSummitEvent) {
        
        self.identifier = realmEntity.id
        self.name = realmEntity.name
        self.start = Date(foundation: realmEntity.start)
        self.end = Date(foundation: realmEntity.end)
        self.descriptionText = realmEntity.eventDescription
        self.allowFeedback = realmEntity.allowFeedback
        self.averageFeedback = realmEntity.averageFeedback
        self.type = realmEntity.eventType.id
        self.summitTypes = realmEntity.summitTypes.identifiers
        self.sponsors = realmEntity.sponsors.identifiers
        self.tags = Tag.from(realm: realmEntity.tags)
        self.presentation = Presentation(realmEntity: realmEntity.presentation!)
        
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
            
        } else {
            
            realmEntity.venue = RealmVenue.cached(location, realm: realm)
            realmEntity.venueRoom = nil
            
        }
        
        return realmEntity
    }
}

