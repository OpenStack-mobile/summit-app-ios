//
//  RealmFeedbackOwner.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 10/3/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import RealmSwift
import SwiftFoundation

public class RealmFeedbackOwner: RealmEntity {
    
    public dynamic var attendeeId = 0
    public dynamic var firstName: String = ""
    public dynamic var lastName: String = ""
}

// MARK: - Encoding

extension FeedbackOwner: RealmEncodable {
    
    public func save(realm: Realm) -> RealmFeedbackOwner {
        
        let realmEntity = RealmType.cached(identifier, realm: realm)
        
        realmEntity.attendeeId = attendee
        realmEntity.firstName = firstName
        realmEntity.lastName = lastName
        
        return realmEntity
    }
}

extension FeedbackOwner: RealmDecodable {
    
    public init(realmEntity: RealmFeedbackOwner) {
        
        self.identifier = realmEntity.id
        self.attendee = realmEntity.attendeeId
        self.firstName = realmEntity.firstName
        self.lastName = realmEntity.lastName
    }
}