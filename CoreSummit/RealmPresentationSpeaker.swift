//
//  RealmPresentationSpeaker.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 5/31/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import RealmSwift

public class RealmPresentationSpeaker: RealmPerson {
    
    public var presentations: [RealmPresentation] {
        
        return self.linkingObjects(RealmPresentation.self, forProperty: "speakers")
    }
    
}

// MARK: - Encoding

//extension Person: RealmEncodable { }

extension PresentationSpeaker: RealmDecodable {
    
    public init(realmEntity: RealmPresentationSpeaker) {
        
        // person
        self.identifier = realmEntity.id
        self.firstName = realmEntity.firstName
        self.lastName = realmEntity.lastName
        self.title = realmEntity.title
        self.pictureURL = realmEntity.pictureUrl
        self.email = realmEntity.email
        self.twitter = realmEntity.twitter
        self.irc = realmEntity.irc
        self.biography = realmEntity.bio
        
        // speaker
        self.memberIdentifier = realmEntity.memberId
    }
}