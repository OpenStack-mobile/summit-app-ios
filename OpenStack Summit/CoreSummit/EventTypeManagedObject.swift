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
    
    @NSManaged public var color: String
    
    @NSManaged public var blackOutTimes: Bool
    
    // Inverse Relationships
    
    @NSManaged public var events: Set<EventManagedObject>
    
    @NSManaged public var summits: Set<SummitManagedObject>
}

extension EventType: CoreDataDecodable {
    
    public init(managedObject: EventTypeManagedObject) {
        
        self.identifier = managedObject.identifier
        self.name = managedObject.name
        self.color = managedObject.color
        self.blackOutTimes = managedObject.blackOutTimes
    }
}

extension EventType: CoreDataEncodable {
    
    public func save(context: NSManagedObjectContext) throws -> EventTypeManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.name = name
        managedObject.color = color
        managedObject.blackOutTimes = blackOutTimes
        
        managedObject.didCache()
        
        return managedObject
    }
}
