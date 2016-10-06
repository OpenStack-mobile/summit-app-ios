//
//  RealmFeedback.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import RealmSwift
import SwiftFoundation

/// Abstract class, should never be instantiated
public class RealmFeedback: RealmEntity {
    
    public dynamic var rate = 0
    public dynamic var review = ""
    public dynamic var date = NSDate(timeIntervalSince1970: 1)
    public dynamic var event: RealmSummitEvent!
}

// Concrete subclasses

public class RealmAttendeeFeedback: RealmFeedback {
    
    public dynamic var member: RealmMember!
    public dynamic var attendee: RealmSummitAttendee!
}

public class RealmReview: RealmFeedback {
    
    public dynamic var memberId = 0
    public dynamic var attendeeId = 0
    public dynamic var firstName: String = ""
    public dynamic var lastName: String = ""
}

// MARK: - Encoding

extension Review: RealmEncodable {
    
    public func save(realm: Realm) -> RealmReview {
        
        let realmEntity = RealmType.cached(identifier, realm: realm)
        
        realmEntity.rate = rate
        realmEntity.review = review
        realmEntity.date = date.toFoundation()
        realmEntity.event = RealmSummitEvent.cached(event, realm: realm)
        realmEntity.memberId = owner.member
        realmEntity.attendeeId = owner.attendee
        realmEntity.firstName = owner.firstName
        realmEntity.lastName = owner.lastName
        
        return realmEntity
    }
}

extension Review: RealmDecodable {
    
    public init(realmEntity: RealmReview) {
        
        self.identifier = realmEntity.id
        self.rate = realmEntity.rate
        self.review = realmEntity.review
        self.date = Date(foundation: realmEntity.date)
        self.event = realmEntity.event.id
        self.owner = Owner(member: realmEntity.memberId, attendee: realmEntity.attendeeId, firstName: realmEntity.firstName, lastName: realmEntity.lastName)
    }
}

extension AttendeeFeedback: RealmEncodable {
    
    public func save(realm: Realm) -> RealmAttendeeFeedback {
        
        let realmEntity = RealmType.cached(identifier, realm: realm)
        
        realmEntity.rate = rate
        realmEntity.review = review
        realmEntity.date = date.toFoundation()
        realmEntity.event = RealmSummitEvent.cached(event, realm: realm)
        realmEntity.member = RealmMember.cached(member, realm: realm)
        realmEntity.attendee = RealmSummitAttendee.cached(attendee, realm: realm)
        
        return realmEntity
    }
}

extension AttendeeFeedback: RealmDecodable {
    
    public init(realmEntity: RealmAttendeeFeedback) {
        
        self.identifier = realmEntity.id
        self.rate = realmEntity.rate
        self.review = realmEntity.review
        self.date = Date(foundation: realmEntity.date)
        self.event = realmEntity.event.id
        self.member = realmEntity.member.id
        self.attendee = realmEntity.attendee.id
    }
}
