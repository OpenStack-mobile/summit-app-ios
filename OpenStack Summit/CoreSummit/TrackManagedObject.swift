//
//  TrackManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData

public final class TrackManagedObject: Entity {
    
    @NSManaged public var name: String
    
    @NSManaged public var groups: Set<TrackGroupManagedObject>
}

extension Track: CoreDataDecodable {
    
    public init(managedObject: TrackManagedObject) {
        
        self.identifier = managedObject.identifier
        self.name = managedObject.name
        self.groups = managedObject.groups.identifiers
    }
}

extension Track: CoreDataEncodable {
    
    public func save(context: NSManagedObjectContext) throws -> TrackManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.name = name
        managedObject.groups = try context.relationshipFault(groups, TrackGroup.self)
        
        managedObject.didCache()
        
        return managedObject
    }
}