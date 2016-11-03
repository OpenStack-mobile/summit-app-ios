//
//  FeedbackManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData
import SwiftFoundation

public class FeedbackManagedObject: Entity {
    
    @NSManaged public var rate: Int16
    
    @NSManaged public var review: String
    
    @NSManaged public var date: NSDate
    
    @NSManaged public var event: EventManagedObject
}

public final class ReviewManagedObject: FeedbackManagedObject {
    
    @NSManaged public var member: Int64
    
    @NSManaged public var attendee: Int64
    
    @NSManaged public var firstName: String
    
    @NSManaged public var lastName: String
}

public final class AttendeeFeedbackManagedObject: FeedbackManagedObject {
    
    @NSManaged public var member: MemberManagedObject
    
    @NSManaged public var attendee: AttendeeManagedObject
}

extension Review: CoreDataDecodable {
    
    public init(managedObject: ReviewManagedObject) {
        
        self.identifier = managedObject.identifier
        self.rate = Int(managedObject.rate)
        self.review = managedObject.review
        self.date = Date(foundation: managedObject.date)
        self.event = managedObject.event.identifier
        
        self.owner = Owner(member: Int(managedObject.member),
                          attendee: Int(managedObject.attendee),
                          firstName: managedObject.firstName,
                          lastName: managedObject.lastName)
    }
}

extension Review: CoreDataEncodable {
    
    public func save(context: NSManagedObjectContext) throws -> ReviewManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.rate = Int16(rate)
        managedObject.review = review
        managedObject.date = date.toFoundation()
        managedObject.event = try context.relationshipFault(event)
        managedObject.member = Int64(owner.member)
        managedObject.attendee = Int64(owner.attendee)
        managedObject.firstName = owner.firstName
        managedObject.lastName = owner.lastName
        
        managedObject.didCache()
        
        return managedObject
    }
}

extension AttendeeFeedback: CoreDataDecodable {
    
    public init(managedObject: AttendeeFeedbackManagedObject) {
        
        self.identifier = managedObject.identifier
        self.rate = Int(managedObject.rate)
        self.review = managedObject.review
        self.date = Date(foundation: managedObject.date)
        self.event = managedObject.event.identifier
        self.member = managedObject.member.identifier
        self.attendee = managedObject.attendee.identifier
    }
}

extension AttendeeFeedback: CoreDataEncodable {
    
    public func save(context: NSManagedObjectContext) throws -> AttendeeFeedbackManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.rate = Int16(rate)
        managedObject.review = review
        managedObject.date = date.toFoundation()
        managedObject.event = try context.relationshipFault(event)
        managedObject.member = try context.relationshipFault(member)
        managedObject.attendee = try context.relationshipFault(attendee)
        
        managedObject.didCache()
        
        return managedObject
    }
}
