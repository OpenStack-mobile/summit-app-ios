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
    
    @NSManaged public var attendee: NSNumber?
    
    @NSManaged public var firstName: String
    
    @NSManaged public var lastName: String
}

public final class MemberFeedbackManagedObject: FeedbackManagedObject {
    
    @NSManaged public var member: MemberManagedObject
}

// MARK: - Encoding

extension Review: CoreDataDecodable {
    
    public init(managedObject: ReviewManagedObject) {
        
        self.identifier = managedObject.identifier
        self.rate = Int(managedObject.rate)
        self.review = managedObject.review
        self.date = Date(foundation: managedObject.date)
        self.event = managedObject.event.identifier
        
        self.owner = Owner(member: Int(managedObject.member),
                           attendee: managedObject.attendee != nil ? Int(managedObject.attendee!) : nil,
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
        managedObject.attendee = owner.attendee != nil ? NSNumber(longLong: Int64(owner.attendee!)) : nil
        managedObject.firstName = owner.firstName
        managedObject.lastName = owner.lastName
        
        managedObject.didCache()
        
        return managedObject
    }
}

extension MemberFeedback: CoreDataDecodable {
    
    public init(managedObject: MemberFeedbackManagedObject) {
        
        self.identifier = managedObject.identifier
        self.rate = Int(managedObject.rate)
        self.review = managedObject.review
        self.date = Date(foundation: managedObject.date)
        self.event = managedObject.event.identifier
        self.member = managedObject.member.identifier
    }
}

extension MemberFeedback: CoreDataEncodable {
    
    public func save(context: NSManagedObjectContext) throws -> MemberFeedbackManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.rate = Int16(rate)
        managedObject.review = review
        managedObject.date = date.toFoundation()
        managedObject.event = try context.relationshipFault(event)
        managedObject.member = try context.relationshipFault(member)
        
        managedObject.didCache()
        
        return managedObject
    }
}

// MARK: - Fetches

public extension FeedbackManagedObject {
    
    static var sortDescriptors: [NSSortDescriptor] {
        
        return [NSSortDescriptor(key: "date", ascending: true)]
    }
}
