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
        self.type = EventType(realmEntity: realmEntity.eventType)
        self.summitTypes = SummitType.from(realm: realmEntity.summitTypes)
        self.sponsors = Company.from(realm: realmEntity.sponsors)
        self.tags = Tag.from(realm: realmEntity.tags)
    }
}

