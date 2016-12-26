//
//  NotificationManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 12/5/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData
import SwiftFoundation

public final class NotificationManagedObject: NSManagedObject {
    
    @NSManaged public var uuid: String
    
    @NSManaged public var cached: NSDate?
    
    @NSManaged public var date: NSDate
    
    @NSManaged public var message: String
    
    @NSManaged public var user: MemberManagedObject?
    
    @NSManaged public var group: NotificationGroupManagedObject
}

// MARK: - Encoding

extension Notification: CoreDataDecodable {
    
    public init(managedObject: NotificationManagedObject) {
        
        self.identifier = UUID(rawValue: managedObject.uuid)!
        self.date = Date(foundation: managedObject.date)
        self.message = managedObject.message
        self.user = managedObject.user?.identifier
        self.group = managedObject.group.identifier
    }
}

extension Notification: CoreDataEncodable {
    
    public func save(context: NSManagedObjectContext) throws -> NotificationManagedObject {
        
        guard let entity = context.persistentStoreCoordinator?.managedObjectModel[ManagedObject.self]
            else { fatalError("Could not find entity") }
        
        let resourceID = self.identifier.rawValue as NSString
        
        let managedObject = try context.findOrCreate(entity,
                                                     resourceID: resourceID,
                                                     identifierProperty: "uuid",
                                                     returnsObjectsAsFaults: true,
                                                     includesSubentities: false) as ManagedObject
        
        managedObject.uuid = identifier.rawValue
        managedObject.date = date.toFoundation()
        managedObject.message = message
        managedObject.user = try context.relationshipFault(user)
        managedObject.group = try context.relationshipFault(group)
        
        managedObject.cached = NSDate()
        
        return managedObject
    }
}
