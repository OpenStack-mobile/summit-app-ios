//
//  RealmSummitAttendee.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 5/31/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import RealmSwift

public class RealmSummitAttendee: RealmPerson {
    
    public let tickets = List<RealmTicketType>()
    public let scheduledEvents = List<RealmSummitEvent>()
    public let bookmarkedEvents = List<RealmSummitEvent>()
    public let friends = List<RealmMember>()
    public let feedback = List<RealmAttendeeFeedback>()
}

// MARK: - Encoding

extension SummitAttendee: RealmDecodable {
    
    public init(realmEntity: RealmSummitAttendee) {
        
        self.identifier = realmEntity.id
        self.firstName = realmEntity.firstName
        self.lastName = realmEntity.lastName
        self.pictureURL = realmEntity.pictureUrl
        
        // optional
        self.twitter = realmEntity.twitter.isEmpty ? nil : realmEntity.twitter
        self.irc = realmEntity.irc.isEmpty ? nil : realmEntity.irc
        self.biography = realmEntity.bio.isEmpty ? nil : realmEntity.bio
        
        self.tickets = TicketType.from(realm: realmEntity.tickets)
        self.feedback = AttendeeFeedback.from(realm: realmEntity.feedback)
        self.scheduledEvents = realmEntity.feedback.identifiers
    }
}

extension SummitAttendee: RealmEncodable {
    
    public func save(realm: Realm) -> RealmSummitAttendee {
        
        let realmEntity = RealmType.cached(identifier, realm: realm)
        
        realmEntity.firstName = firstName
        realmEntity.lastName = lastName
        realmEntity.pictureUrl = pictureURL
        
        realmEntity.twitter = twitter ?? ""
        realmEntity.irc = irc ?? ""
        realmEntity.bio = biography ?? ""
        
        realmEntity.tickets.replace(with: tickets)
        realmEntity.scheduledEvents.replace(with: scheduledEvents)
        realmEntity.feedback.replace(with: feedback)
        
        return realmEntity
    }
}
