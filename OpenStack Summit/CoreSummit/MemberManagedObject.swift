//
//  MemberManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData
import Foundation

public final class MemberManagedObject: Entity {
    
    @NSManaged public var firstName: String
    
    @NSManaged public var lastName: String
    
    @NSManaged public var gender: String?
    
    @NSManaged public var pictureURL: String
    
    @NSManaged public var twitter: String?
    
    @NSManaged public var linkedIn: String?
    
    @NSManaged public var irc: String?
    
    @NSManaged public var biography: String?
    
    @NSManaged public var speakerRole: SpeakerManagedObject?
    
    @NSManaged public var attendeeRole: AttendeeManagedObject?
    
    @NSManaged public var schedule: Set<EventManagedObject>
    
    @NSManaged public var groups: Set<GroupManagedObject>
    
    @NSManaged public var groupEvents: Set<EventManagedObject>
    
    @NSManaged public var feedback: Set<FeedbackManagedObject>
    
    @NSManaged public var favoriteEvents: Set<EventManagedObject>
    
    @NSManaged public var affiliations: Set<AffiliationManagedObject>
}

// MARK: - Encoding

extension Member: CoreDataDecodable {
    
    public init(managedObject: MemberManagedObject) {
        
        self.identifier = managedObject.id
        self.firstName = managedObject.firstName
        self.lastName = managedObject.lastName
        self.picture = URL(string: managedObject.pictureURL)!
        self.twitter = managedObject.twitter
        self.irc = managedObject.irc
        self.linkedIn = managedObject.linkedIn
        self.biography = managedObject.biography
        self.gender = managedObject.gender
        self.schedule = managedObject.schedule.identifiers
        self.groups = Group.from(managedObjects: managedObject.groups)
        self.feedback = managedObject.feedback.identifiers
        self.groupEvents = managedObject.groupEvents.identifiers
        self.favoriteEvents = managedObject.favoriteEvents.identifiers
        self.affiliations = Affiliation.from(managedObjects: managedObject.affiliations)
        
        if let managedObject = managedObject.speakerRole {
            
            self.speakerRole = Speaker(managedObject: managedObject)
            
        } else {
            
            self.speakerRole = nil
        }
        
        if let managedObject = managedObject.attendeeRole {
            
            self.attendeeRole = Attendee(managedObject: managedObject)
            
        } else {
            
            self.attendeeRole = nil
        }
    }
}

extension Member: CoreDataEncodable {
    
    public func save(_ context: NSManagedObjectContext) throws -> MemberManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.firstName = firstName
        managedObject.lastName = lastName
        managedObject.pictureURL = picture.absoluteString
        managedObject.twitter = twitter
        managedObject.irc = irc
        managedObject.linkedIn = linkedIn
        managedObject.biography = biography
        managedObject.gender = gender
        managedObject.schedule = try context.relationshipFault(schedule)
        managedObject.groups = try context.relationshipFault(groups)
        managedObject.affiliations = try context.relationshipFault(affiliations)
        
        if speakerRole != nil {
            
            managedObject.speakerRole = try context.relationshipFault(speakerRole)
        }
        
        if attendeeRole != nil {
            
            managedObject.attendeeRole = try context.relationshipFault(attendeeRole)
        }
                
        // dont touch group events, favorites, feedback
        
        managedObject.didCache()
        
        return managedObject
    }
}

extension MemberResponse.Member: CoreDataEncodable {
    
    public func save(_ context: NSManagedObjectContext) throws -> MemberManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.firstName = firstName
        managedObject.lastName = lastName
        managedObject.pictureURL = picture.absoluteString
        managedObject.twitter = twitter
        managedObject.irc = irc
        managedObject.linkedIn = linkedIn
        managedObject.biography = biography
        managedObject.gender = gender
        
        managedObject.speakerRole = try context.relationshipFault(speakerRole)
        managedObject.attendeeRole = try context.relationshipFault(attendeeRole)
        managedObject.groups = try context.relationshipFault(Set(groups))
        managedObject.feedback = try context.relationshipFault(Set(feedback))
        managedObject.groupEvents = try context.relationshipFault(Set(groupEvents))
        managedObject.favoriteEvents = try context.relationshipFault(Set(favoriteEvents))
        managedObject.affiliations = try context.relationshipFault(Set(affiliations))
        
        managedObject.didCache()
        
        return managedObject
    }
}

// MARK: - Fetch

public extension MemberManagedObject {
    
    @inline(__always)
    func isScheduled(event: Identifier) -> Bool {
        
        return schedule.contains(where: { $0.id == event }) 
    }
    
    @inline(__always)
    func isFavorite(event: Identifier) -> Bool {
        
        return favoriteEvents.contains(where: { $0.id == event })
    }
    
    @inline(__always)
    func feedback(for event: Identifier) -> FeedbackManagedObject? {
        
        return feedback.first(where: { $0.event.id == event })
    }
}

// MARK: - Store

public extension Store {
    
    /// The member that is logged in.
    var authenticatedMember: MemberManagedObject? {
        
        return try! self.authenticatedMember(self.managedObjectContext)
    }
    
    /// The member that is logged in.
    internal func authenticatedMember(_ context: NSManagedObjectContext) throws -> MemberManagedObject? {
        
        guard let memberID = session.member,
            let member = try MemberManagedObject.find(memberID, context: context)
            else { return nil }
        
        return member
    }
    
    var isLoggedIn: Bool {
        
        return self.session.member != nil
    }
    
    var isLoggedInAndConfirmedAttendee: Bool {
        
        return authenticatedMember?.attendeeRole != nil
    }
    
    @inline(__always)
    func isEventScheduledByLoggedMember(event eventID: Identifier) -> Bool {
        
        return self.authenticatedMember?.schedule.contains(where: { $0.id == eventID }) ?? false
    }
}
