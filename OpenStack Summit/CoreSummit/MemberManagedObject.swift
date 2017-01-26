//
//  MemberManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData
import SwiftFoundation

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
    
    @NSManaged public var groups: Set<GroupManagedObject>
    
    @NSManaged public var groupEvents: Set<EventManagedObject>
    
    @NSManaged public var feedback: Set<MemberFeedbackManagedObject>
}

// MARK: - Encoding

extension Member: CoreDataDecodable {
    
    public init(managedObject: MemberManagedObject) {
        
        self.identifier = managedObject.identifier
        self.firstName = managedObject.firstName
        self.lastName = managedObject.lastName
        self.pictureURL = managedObject.pictureURL
        self.twitter = managedObject.twitter
        self.irc = managedObject.irc
        self.linkedIn = managedObject.linkedIn
        self.biography = managedObject.biography
        self.gender = managedObject.gender
        self.groups = Group.from(managedObjects: managedObject.groups)
        self.groupEvents = managedObject.groups.identifiers
        self.feedback = MemberFeedback.from(managedObjects: managedObject.feedback)
        
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
    
    public func save(context: NSManagedObjectContext) throws -> MemberManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.firstName = firstName
        managedObject.lastName = lastName
        managedObject.pictureURL = pictureURL
        managedObject.twitter = twitter
        managedObject.irc = irc
        managedObject.linkedIn = linkedIn
        managedObject.biography = biography
        managedObject.gender = gender
        managedObject.groups = try context.relationshipFault(groups)
        
        if speakerRole != nil {
            
            managedObject.speakerRole = try context.relationshipFault(speakerRole)
        }
        
        if attendeeRole != nil {
            
            managedObject.attendeeRole = try context.relationshipFault(attendeeRole)
        }
                
        // dont touch group events, feedback
        
        managedObject.didCache()
        
        return managedObject
    }
}

extension MemberResponse.Member: CoreDataEncodable {
    
    public func save(context: NSManagedObjectContext) throws -> MemberManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.firstName = firstName
        managedObject.lastName = lastName
        managedObject.pictureURL = pictureURL
        managedObject.twitter = twitter
        managedObject.irc = irc
        managedObject.linkedIn = linkedIn
        managedObject.biography = biography
        managedObject.gender = gender
        
        managedObject.speakerRole = try context.relationshipFault(speakerRole)
        managedObject.attendeeRole = try context.relationshipFault(attendeeRole)
        managedObject.groups = try context.relationshipFault(Set(groups))
        managedObject.groupEvents = try context.relationshipFault(Set(groupEvents))
        managedObject.feedback = try context.relationshipFault(Set(feedback))
        
        managedObject.didCache()
        
        return managedObject
    }
}

// MARK: - Fetch

public extension MemberManagedObject {
    
    func feedback(for event: Identifier) -> MemberFeedbackManagedObject? {
        
        return feedback.firstMatching({ $0.event.identifier == event})
    }
    
    var givenFeedback: [MemberFeedbackManagedObject] {
        
        return feedback.sort { Date(foundation: $0.0.date) < Date(foundation: $0.1.date) } ?? []
    }
}

// MARK: - Store

public extension Store {
    
    /// The member that is logged in.
    var authenticatedMember: MemberManagedObject? {
        
        return try! self.authenticatedMember(self.managedObjectContext)
    }
    
    /// The member that is logged in.
    internal func authenticatedMember(context: NSManagedObjectContext) throws -> MemberManagedObject? {
        
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
    
    func isEventScheduledByLoggedMember(event eventID: Identifier) -> Bool {
        
        guard let loggedInMember = self.authenticatedMember
            where self.isLoggedInAndConfirmedAttendee
            else { return false }
        
        return loggedInMember.attendeeRole?.schedule.contains({ $0.identifier == eventID }) ?? false
    }
}
