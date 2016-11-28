//
//  EventTypeManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData

public final class EventTypeManagedObject: Entity {
    
    @NSManaged public var name: String
    
    // Inverse Relationships
    
    @NSManaged public var events: Set<EventManagedObject>
    
    @NSManaged public var summits: Set<SummitManagedObject>
}

extension EventType: CoreDataDecodable {
    
    public init(managedObject: EventTypeManagedObject) {
        
        self.identifier = managedObject.identifier
        self.name = managedObject.name
    }
}

extension EventType: CoreDataEncodable {
    
    public func save(context: NSManagedObjectContext) throws -> EventTypeManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.name = name
        
        managedObject.didCache()
        
        return managedObject
    }
}