//
//  Entity.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData

/// Base CoreData Entity `NSManagedObject` subclass for CoreSummit.
public class Entity: NSManagedObject {
    
    /// The unique identifier of this entity.
    @NSManaged final var id: Int64
}

// MARK: - Extensions

public extension Entity {
    
    static var identifierProperty: String { return "id" }
    
    static func entity(in context: NSManagedObjectContext) -> NSEntityDescription {
        
        let className = NSStringFromClass(self as AnyClass)
        
        struct Cache {
            static var entities = [String: NSEntityDescription]()
        }
        
        // try to get from cache
        if let entity = Cache.entities[className] {
            
            return entity
        }
        
        // search for entity with class name
        guard let entity = context.persistentStoreCoordinator?.managedObjectModel.entities
            .firstMatching({ $0.managedObjectClassName == className })
            else { fatalError("Could not find entity for \(self) in managed object context") }
        
        Cache.entities[className] = entity
        
        return entity
    }
    
    static func find(identifier: Int,
                     context: NSManagedObjectContext,
                     returnsObjectsAsFaults: Bool = true,
                     includesSubentities: Bool = true) -> Self? {
        
        let entity = self.entity(in: context)
        
        let resourceID = NSNumber(longLong: Int64(identifier))
        
        return try! context.find(entity, resourceID: resourceID, identifierProperty: self.identifierProperty, returnsObjectsAsFaults: returnsObjectsAsFaults, includesSubentities: includesSubentities)
    }
    
    /// Find or create.
    static func cached(identifier: Int,
                       context: NSManagedObjectContext,
                       returnsObjectsAsFaults: Bool = true,
                       includesSubentities: Bool = true) -> Self {
        
        let entity = self.entity(in: context)
        
        let resourceID = NSNumber(longLong: Int64(identifier))
        
        return try! context.findOrCreate(entity, resourceID: resourceID, identifierProperty: self.identifierProperty, returnsObjectsAsFaults: returnsObjectsAsFaults, includesSubentities: includesSubentities)
    }
}

public extension CollectionType where Generator.Element: Entity {
    
    var identifiers: [Identifier] { return self.map { Int($0.id) } }
}

public extension CoreDataEncodable where ManagedObject: Entity {
    
    static func save(identifiers: [Identifier], context: NSManagedObjectContext) -> Set<ManagedObject> {
        
        return Set(identifiers.map({ ManagedObject.cached($0, context: context, returnsObjectsAsFaults: true, includesSubentities: true) }))
    }
}

public extension CoreDataDecodable where ManagedObject: Entity {
    
    static func from(identifiers: [Identifier], context: NSManagedObjectContext) -> [Self] {
        
        return identifiers.map { self.init(managedObject: ManagedObject.cached($0, context: context, returnsObjectsAsFaults: false, includesSubentities: true)) }
    }
}
