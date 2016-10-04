//
//  RealmFeedback.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import RealmSwift
import SwiftFoundation

public class RealmFeedback: RealmEntity {
    
    public dynamic var rate = 0
    public dynamic var review = ""
    public dynamic var date = NSDate(timeIntervalSince1970: 1)
    public dynamic var event: RealmSummitEvent!
    
    // owner
    public dynamic var memberId = 0
    public dynamic var attendeeId = 0
    public dynamic var firstName: String = ""
    public dynamic var lastName: String = ""
    public dynamic var ownerType: String = ""
}

// MARK: - Encoding

extension Feedback: RealmDecodable where Feedback: FeedbackNamedOwner {
    
    public init(realmEntity: RealmFeedback) {
        
        assert(realmEntity.ownerType == "\(Owner.self)", "Invalid owner type: \(realmEntity.ownerType) != \(Owner.self)")
        
        switch realmEntity.ownerType {
            
        case "\(FeedbackNamedOwner.self)":
            
            self = Feedback<FeedbackNamedOwner>.
            
        case "\(FeedbackMemberOwner.self)":
            
            let owner = FeedbackMemberOwner(identifier: realmEntity.memberId, attendee: realmEntity.attendeeId)
            
            self.owner = owner as! Owner
            
        default: fatalError("Invalid feedback owner type: \(Owner.self)")
        }
    }
}

extension Feedback: RealmEncodable {
    
    public func save(realm: Realm) -> Self.RealmType {
        
        
    }
}

// MARK: Generic Variants

/// In order to use conditional protocol extensions
internal protocol _FeedbackNamedOwnerProtocol: FeedbackOwner {
    var firstName: String { get }
    var lastName: String { get }
    init(identifier: Identifier, attendee: Identifier, firstName: String, lastName: String)
}

extension FeedbackNamedOwner: _FeedbackNamedOwnerProtocol { }

internal extension Feedback where Owner: _FeedbackNamedOwnerProtocol  {
    
    func save(realm: Realm) -> RealmFeedback {
        
        let realmEntity = RealmType.cached(identifier, realm: realm)
        
        realmEntity.rate = rate
        realmEntity.review = review
        realmEntity.date = date.toFoundation()
        realmEntity.event = RealmSummitEvent.cached(event, realm: realm)
        realmEntity.memberId = owner.identifier
        realmEntity.attendeeId = owner.attendee
        realmEntity.firstName = owner.firstName
        realmEntity.lastName = owner.lastName
        realmEntity.ownerType = "\(self.dynamicType)"
        
        return realmEntity
    }
    
    init(realmEntity: RealmFeedback) {
        
        self.identifier = realmEntity.id
        self.rate = realmEntity.rate
        self.review = realmEntity.review
        self.date = Date(foundation: realmEntity.date)
        self.event = realmEntity.event.id
        self.owner = Owner(identifier: realmEntity.memberId, attendee: realmEntity.attendeeId, firstName: realmEntity.firstName, lastName: realmEntity.lastName)
    }
}

/// In order to use conditional protocol extensions
internal protocol _FeedbackMemberOwnerProtocol: FeedbackOwner {
    init(identifier: Identifier, attendee: Identifier)
}

extension FeedbackMemberOwner: _FeedbackMemberOwnerProtocol { }

internal extension Feedback where Owner: _FeedbackMemberOwnerProtocol  {
    
    func save(realm: Realm) -> RealmFeedback {
        
        let realmEntity = RealmType.cached(identifier, realm: realm)
        
        realmEntity.rate = rate
        realmEntity.review = review
        realmEntity.date = date.toFoundation()
        realmEntity.event = RealmSummitEvent.cached(event, realm: realm)
        realmEntity.memberId = owner.identifier
        realmEntity.attendeeId = owner.attendee
        realmEntity.firstName = ""
        realmEntity.lastName = ""
        realmEntity.ownerType = "\(self.dynamicType)"
        
        return realmEntity
    }
    
    init(realmEntity: RealmFeedback) {
        
        self.identifier = realmEntity.id
        self.rate = realmEntity.rate
        self.review = realmEntity.review
        self.date = Date(foundation: realmEntity.date)
        self.event = realmEntity.event.id
        self.owner = Owner(identifier: realmEntity.memberId, attendee: realmEntity.attendeeId)
    }
}
