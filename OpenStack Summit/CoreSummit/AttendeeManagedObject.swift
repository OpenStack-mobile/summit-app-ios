//
//  AttendeeManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData

public final class AttendeeManagedObject: Entity {
    
    @NSManaged public var firstName: String
    
    @NSManaged public var lastName: String
    
    @NSManaged public var pictureURL: String
    
    @NSManaged public var twitter: String?
    
    @NSManaged public var irc: String?
    
    @NSManaged public var biography: String?
    
    @NSManaged public var tickets: Set<TicketTypeManagedObject>
    
    @NSManaged public var scheduledEvents: Set<EventManagedObject>
    
    @NSManaged public var feedback: Set<AttendeeFeedbackManagedObject>
}

extension Attendee: CoreDataDecodable {
    
    public init(managedObject: AttendeeManagedObject) {
        
        self.identifier = managedObject.identifier
        self.firstName = managedObject.firstName
        self.lastName = managedObject.lastName
        self.pictureURL = managedObject.pictureURL
        self.twitter = managedObject.twitter
        self.irc = managedObject.irc
        self.tickets = TicketType.from(managedObjects: managedObject.tickets)
        self.scheduledEvents = managedObject.scheduledEvents.identifiers
        self.feedback = AttendeeFeedback.from(managedObjects: managedObject.feedback)
    }
}

extension Attendee: CoreDataEncodable {
    
    public func save(context: NSManagedObjectContext) throws -> AttendeeManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.firstName = firstName
        managedObject.lastName = lastName
        managedObject.pictureURL = pictureURL
        managedObject.twitter = twitter
        managedObject.irc = irc
        managedObject.biography = biography
        managedObject.tickets = try context.relationshipFault(tickets)
        managedObject.scheduledEvents = try context.relationshipFault(scheduledEvents, Event.self)
        managedObject.feedback = try context.relationshipFault(feedback)
        
        managedObject.didCache()
        
        return managedObject
    }
}
