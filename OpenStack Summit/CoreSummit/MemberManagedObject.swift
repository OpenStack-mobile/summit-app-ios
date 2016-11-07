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
    
    @NSManaged public var pictureURL: String
    
    @NSManaged public var twitter: String?
    
    @NSManaged public var irc: String?
    
    @NSManaged public var biography: String?
    
    @NSManaged public var speakerRole: SpeakerManagedObject?
    
    @NSManaged public var attendeeRole: AttendeeManagedObject?
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
        self.biography = managedObject.biography
        
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
        managedObject.biography = biography
        managedObject.speakerRole = try context.relationshipFault(speakerRole)
        managedObject.attendeeRole = try context.relationshipFault(attendeeRole)
        
        managedObject.didCache()
        
        return managedObject
    }
}

// MARK: - Fetch

public extension MemberManagedObject {
    
    func feedback(for event: Identifier) -> AttendeeFeedbackManagedObject? {
        
        return attendeeRole?.feedback.firstMatching({ $0.event.identifier == event})
    }
    
    var givenFeedback: [AttendeeFeedbackManagedObject] {
        
        return attendeeRole?.feedback.sort { Date(foundation: $0.0.date) < Date(foundation: $0.1.date) } ?? []
    }
}

// MARK: - Store

public extension Store {
    
    /// The member that is logged in. Only valid for confirmed attendees.
    var authenticatedMember: MemberManagedObject? {
        
        return try! self.authenticatedMember(self.managedObjectContext)
    }
    
    /// The member that is logged in. Only valid for confirmed attendees.
    internal func authenticatedMember(context: NSManagedObjectContext) throws -> MemberManagedObject? {
        
        guard let sessionMember = session.member,
            case let .attendee(memberID) = sessionMember,
            let member = try MemberManagedObject.find(memberID, context: context)
            else { return nil }
        
        return member
    }
    
    var isLoggedIn: Bool {
        
        return self.session.member != nil
    }
    
    var isLoggedInAndConfirmedAttendee: Bool {
        
        guard let sessionMember = session.member,
            case .attendee(_) = sessionMember
            else { return false }
        
        return true
    }
    
    func isEventScheduledByLoggedMember(event eventID: Identifier) -> Bool {
        
        guard let loggedInMember = self.authenticatedMember
            where self.isLoggedInAndConfirmedAttendee
            else { return false }
        
        return loggedInMember.attendeeRole?.scheduledEvents.contains({ $0.identifier == eventID }) ?? false
    }
}
