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
    
    public init(realm: RealmPerson) {
        
        // person
        self.identifier = realm.id
        self.firstName = realm.firstName
        self.lastName = realm.lastName
        self.title = realm.title
        self.pictureURL = realm.pictureUrl
        self.email = realm.email
        self.twitter = realm.twitter
        self.irc = realm.irc
        self.biography = realm.bio
        
        // speaker
        self.memberIdentifier = realm.memberId
    }
}