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
    
    @NSManaged public var member: MemberManagedObject
}

// MARK: - Encoding

extension Feedback: CoreDataDecodable {
    
    public init(managedObject: FeedbackManagedObject) {
        
        self.identifier = managedObject.identifier
        self.rate = Int(managedObject.rate)
        self.review = managedObject.review
        self.date = Date(foundation: managedObject.date)
        self.event = managedObject.event.identifier
        self.member = Member(managedObject: managedObject.member)
    }
}

extension Feedback: CoreDataEncodable {
    
    public func save(context: NSManagedObjectContext) throws -> FeedbackManagedObject {
        
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

extension MemberResponse.Feedback: CoreDataEncodable {
    
    public func save(context: NSManagedObjectContext) throws -> FeedbackManagedObject {
        
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
