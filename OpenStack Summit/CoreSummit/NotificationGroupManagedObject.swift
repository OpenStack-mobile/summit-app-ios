//
//  GroupManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 12/5/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData

public final class NotificationGroupManagedObject: Entity {
    
    @NSManaged public var name: String
    
    @NSManaged public var notifications: Set<NotificationManagedObject>
}

// MARK: - Encoding

extension NotificationGroup: CoreDataDecodable {
    
    public init(managedObject: NotificationGroupManagedObject) {
        
        self.identifier = managedObject.identifier
        self.name = managedObject.name
    }
}

extension NotificationGroup: CoreDataEncodable {
    
    public func save(context: NSManagedObjectContext) throws -> NotificationGroupManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.name = name
        
        managedObject.didCache()
        
        return managedObject
    }
}

// MARK: - Fetches

public extension NotificationGroupManagedObject {
    
    static var sortDescriptors: [NSSortDescriptor] {
        
        return [NSSortDescriptor(key: "name", ascending: true)]
    }
}
