//
//  RealmPerson.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 5/31/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import RealmSwift

public class RealmPerson: RealmEntity {
    
    public dynamic var firstName = ""
    public dynamic var lastName = ""
    public dynamic var fullName = ""
    public dynamic var title = ""
    public dynamic var pictureUrl = ""
    public dynamic var bio = ""
    public dynamic var twitter = ""
    public dynamic var irc = ""
    public dynamic var email = ""
    public dynamic var location = ""
    public dynamic var memberId = 0
}

// MARK: - Encoding

//extension Person: RealmEncodable { }

extension Person: RealmDecodable {
    
    public init(realm: RealmPerson) {
        
        self.identifier = realm.id
        self.firstName = realm.firstName
        self.lastName = realm.lastName
        self.title = realm.title
        self.title = realm.title
        self.pictureURL = realm.pictureUrl
        self.attendee = realm is RealmSummitAttendee
        self.speaker = realm is RealmPresentationSpeaker
    }
}