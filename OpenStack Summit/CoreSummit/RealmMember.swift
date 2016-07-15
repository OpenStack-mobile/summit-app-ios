//
//  RealmMember.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import RealmSwift

public class RealmMember: RealmPerson {
    public dynamic var speakerRole : RealmPresentationSpeaker?
    public dynamic var attendeeRole : RealmSummitAttendee?
    public let friends = List<RealmMember>()
    
    public func isFriend(member: RealmMember) -> Bool {
        let isFriend = friends.filter({ friend in friend.id == member.id }).count > 0
        return isFriend
    }
}

// MARK: - Fetch

public extension Store {
    
    func isEventScheduledByLoggedMember(event eventID: Int) -> Bool {
        
        /* FIXME: Implement Login
         if !Store.shared.isLoggedInAndConfirmedAttendee() {
         return false;
         } */
        
        guard let loggedInMember = Store.shared.authenticatedMember else {
            return false
        }
        
        return loggedInMember.attendeeRole?.scheduledEvents.filter("id = \(eventID)").count > 0
    }
}

public extension RealmMember {
    
    func isEventScheduledByLoggedMember(eventId: Int) -> Bool {
        
        /* FIXME: Implement Login
         if !Store.shared.isLoggedInAndConfirmedAttendee() {
         return false;
         } */
        
        guard let loggedInMember = Store.shared.authenticatedMember else {
            return false
        }
        
        return loggedInMember.attendeeRole?.scheduledEvents.filter("id = \(eventId)").count > 0
    }
    
    func feedback(forEvent eventID: Identifier) -> RealmFeedback? {
        
        return attendeeRole?.feedback.filter("event.id = %@", eventID).first
    }
    
    var givenFeedback: [RealmFeedback] {
        
        return attendeeRole?.feedback.sorted("date", ascending: false).map { $0 } ?? []
    }
}

// MARK: - Encoding

extension Member: RealmDecodable {
    
    public init(realmEntity: RealmMember) {
        
        // person
        self.identifier = realmEntity.id
        self.firstName = realmEntity.firstName
        self.lastName = realmEntity.lastName
        self.pictureURL = realmEntity.pictureUrl
        self.email = realmEntity.email
        self.biography = realmEntity.bio
        
        // optional
        self.twitter = realmEntity.twitter.isEmpty ? nil : realmEntity.twitter
        self.irc = realmEntity.irc.isEmpty ? nil : realmEntity.irc
        self.title = realmEntity.title.isEmpty ? nil : realmEntity.title
        self.biography = realmEntity.bio.isEmpty ? nil : realmEntity.bio
        
        if let speaker = realmEntity.speakerRole {
            
            self.speakerRole = PresentationSpeaker(realmEntity: speaker)
            
        } else {
            
            self.speakerRole = nil
        }
        
        if let attendee = realmEntity.attendeeRole {
            
            self.attendeeRole = SummitAttendee(realmEntity: attendee)
            
        } else {
            
            self.attendeeRole = nil
        }
    }
}

extension Member: RealmEncodable {
    
    public func save(realm: Realm) -> RealmMember {
        
        let realmEntity = RealmType.cached(identifier, realm: realm)
        
        realmEntity.firstName = firstName
        realmEntity.lastName = lastName
        realmEntity.title = title ?? ""
        realmEntity.pictureUrl = pictureURL
        realmEntity.email = email
        realmEntity.twitter = twitter ?? ""
        realmEntity.irc = irc ?? ""
        realmEntity.bio = biography ?? ""
        
        return realmEntity
    }
}