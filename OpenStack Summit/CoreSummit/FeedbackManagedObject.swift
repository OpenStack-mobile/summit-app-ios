//
//  FeedbackManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData
import Foundation

open class FeedbackManagedObject: Entity {
    
    @NSManaged open var rate: Int16
    
    @NSManaged open var review: String
    
    @NSManaged open var date: Date
    
    @NSManaged open var event: EventManagedObject
    
    @NSManaged open var member: MemberManagedObject
}

// MARK: - Encoding

extension Feedback: CoreDataDecodable {
    
    public init(managedObject: FeedbackManagedObject) {
        
        self.identifier = managedObject.id
        self.rate = Int(managedObject.rate)
        self.review = managedObject.review
        self.date = managedObject.date
        self.event = managedObject.event.id
        self.member = Member(managedObject: managedObject.member)
    }
}

extension Feedback: CoreDataEncodable {
    
    public func save(_ context: NSManagedObjectContext) throws -> FeedbackManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.rate = Int16(rate)
        managedObject.review = review
        managedObject.date = date
        managedObject.event = try context.relationshipFault(event)
        managedObject.member = try context.relationshipFault(member)
        
        managedObject.didCache()
        
        return managedObject
    }
}

extension MemberResponse.Feedback: CoreDataEncodable {
    
    public func save(_ context: NSManagedObjectContext) throws -> FeedbackManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.rate = Int16(rate)
        managedObject.review = review
        managedObject.date = date
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
