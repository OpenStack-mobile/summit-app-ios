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
    public let feedback = List<RealmFeedback>()
}

// MARK: - Encoding

extension SummitAttendee: RealmDecodable {
    
    public init(realmEntity: RealmSummitAttendee) {
        
        self.identifier = realmEntity.id
        self.firstName = realmEntity.firstName
        self.lastName = realmEntity.lastName
        self.title = realmEntity.title
        self.pictureURL = realmEntity.pictureUrl
        self.email = realmEntity.email
        self.twitter = realmEntity.twitter
        self.irc = realmEntity.irc
        self.biography = realmEntity.bio
        
        self.tickets = TicketType.from(realm: realmEntity.tickets)
        self.scheduledEvents = Event.from(realm: realmEntity.scheduledEvents)
        self.feedback = Feedback.from(realm: realmEntity.feedback)
    }
}