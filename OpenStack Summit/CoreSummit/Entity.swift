//
//  Entity.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData
import Predicate

/// Base CoreData Entity `NSManagedObject` subclass for CoreSummit.
open class Entity: NSManagedObject {
    
    /// The unique identifier of this entity.
    @NSManaged open var id: Int64
    
    /// The date this object was stored in its entirety.
    @NSManaged open var cached: Date?
}

// MARK: - Extensions

public extension NSManagedObjectModel {
    
    /// CoreData Managed Object Model for CoreSummit framework (OpenStack Foundation Summit).
    static var summitModel: NSManagedObjectModel {
        
        guard let bundle = Bundle(identifier: "org.openstack.CoreSummit"),
            let modelURL = bundle.url(forResource: "Model", withExtension: "momd"),
            let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL)
            else { fatalError("Could not load managed object model") }
        
        return managedObjectModel
    }
}

public extension Entity {
    
    static var identifierProperty: String { return "id" }
        
    func didCache() {
        
        self.cached = Date()
    }
    
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
        guard let entity = context.persistentStoreCoordinator?.managedObjectModel[self]
            else { fatalError("Could not find entity") }
        
        Cache.entities[className] = entity
        
        return entity
    }
    
    static func find(_ identifier: Identifier,
                     context: NSManagedObjectContext,
                     returnsObjectsAsFaults: Bool = true,
                     includesSubentities: Bool = true) throws -> Self? {
        
        let entity = self.entity(in: context)
        
        let resourceID = NSNumber(value: Int64(identifier) as Int64)
        
        return try context.find(entity, resourceID: resourceID, identifierProperty: self.identifierProperty, returnsObjectsAsFaults: returnsObjectsAsFaults, includesSubentities: includesSubentities)
    }
    
    /// Find or create.
    static func cached(_ identifier: Identifier,
                       context: NSManagedObjectContext,
                       returnsObjectsAsFaults: Bool = true,
                       includesSubentities: Bool = true) throws -> Self {
        
        let entity = self.entity(in: context)
        
        let resourceID = NSNumber(value: Int64(identifier) as Int64)
        
        return try context.findOrCreate(entity, resourceID: resourceID, identifierProperty: self.identifierProperty, returnsObjectsAsFaults: returnsObjectsAsFaults, includesSubentities: includesSubentities)
    }
    
    static func filter(_ predicate: NSPredicate? = nil,
                       sort: [NSSortDescriptor] = [NSSortDescriptor(key: Entity.identifierProperty, ascending: true)],
                       fetchLimit: Int? = nil,
                       returnsObjectsAsFaults: Bool = true,
                       includesSubentities: Bool = true,
                       context: NSManagedObjectContext) throws -> [Entity] {
        
        let entity = self.entity(in: context)
        
        let fetchRequest = NSFetchRequest<Entity>(entityName: entity.name!)
        
        if let limit = fetchLimit {
            
            fetchRequest.fetchLimit = limit
        }
        
        fetchRequest.includesSubentities = includesSubentities
        
        fetchRequest.returnsObjectsAsFaults = returnsObjectsAsFaults
        
        fetchRequest.predicate = predicate
        
        fetchRequest.sortDescriptors = sort
        
        return try context.fetch(fetchRequest)
    }
}

public extension Fault where Value: CoreDataDecodable, Value.ManagedObject: Entity {
    
    init(managedObject: Value.ManagedObject) {
        
        if (managedObject.cached != nil) {
            
            let decoded = Value.init(managedObject: managedObject)
            
            self = .value(decoded)
            
        } else {
            
            self = .identifier(managedObject.id)
        }
    }
}

public extension Collection where Iterator.Element: Entity {
    
    var identifiers: Set<Identifier> { return Set(self.map({ $0.id })) }
}

public extension CoreDataDecodable where Self: Unique, ManagedObject: Entity {
    
    @inline(__always)
    static func find(_ identifier: Identifier,
                     context: NSManagedObjectContext,
                     includesSubentities: Bool = true) throws -> Self? {
        
        guard let managedObject = try ManagedObject.find(identifier,
                                                         context: context,
                                                         returnsObjectsAsFaults: false,
                                                         includesSubentities: includesSubentities)
            else { return nil }
        
        return Self.init(managedObject: managedObject)
    }
    
    static func filter(_ predicate: NSPredicate,
                       sort: [NSSortDescriptor] = [NSSortDescriptor(key: Entity.identifierProperty, ascending: true)],
                       fetchLimit: Int? = nil,
                       context: NSManagedObjectContext) throws -> [Self] {
        
        let managedObjects = try ManagedObject.filter(predicate,
                                                      sort: sort,
                                                      fetchLimit: fetchLimit,
                                                      returnsObjectsAsFaults: false,
                                                      includesSubentities: true,
                                                      context: context) as! [ManagedObject]
        
        return Self.from(managedObjects: managedObjects)
    }
    
    static func filter(_ predicate: Predicate,
                       sort: [NSSortDescriptor] = [NSSortDescriptor(key: Entity.identifierProperty, ascending: true)],
                       fetchLimit: Int? = nil,
                       context: NSManagedObjectContext) throws -> [Self] {
        
        let managedObjects = try ManagedObject.filter(predicate.toFoundation(),
                                                      sort: sort,
                                                      fetchLimit: fetchLimit,
                                                      returnsObjectsAsFaults: false,
                                                      includesSubentities: true,
                                                      context: context) as! [ManagedObject]
        
        return Self.from(managedObjects: managedObjects)
    }
    
    static func all(_ context: NSManagedObjectContext) throws -> [Self] {
        
        let managedObjects = try ManagedObject.filter(returnsObjectsAsFaults: false,
                                                      includesSubentities: true,
                                                      context: context) as! [ManagedObject]
        
        return Self.from(managedObjects: managedObjects)
    }
}

public extension CoreDataEncodable where Self: Unique, ManagedObject: Entity {
    
    @inline(__always)
    func cached(_ context: NSManagedObjectContext) throws -> ManagedObject {
        
        return try ManagedObject.cached(self.identifier, context: context, returnsObjectsAsFaults: true, includesSubentities: true)
    }
}

public extension EntityController {
    
    @inline(__always)
    convenience init(identifier: Identifier, entity: Entity.Type, context: NSManagedObjectContext) {
        
        let entity = entity.entity(in: context)
        
        let entityName = entity.name!
        
        let resourceID = NSNumber(value: Int64(identifier) as Int64)
        
        self.init(entityName: entityName, identifier: (key: Entity.identifierProperty, value: resourceID), context: context)
    }
}

internal extension NSManagedObjectContext {
    
    /// Caches to-many relationship.
    @inline(__always)
    func relationshipFault<T: CoreDataEncodable>(_ encodables: Set<T>) throws -> Set<T.ManagedObject> {
        
        return try encodables.save(self)
    }
    
    /// Caches to-one relationship.
    @inline(__always)
    func relationshipFault<T: CoreDataEncodable>(_ encodable: T?) throws -> T.ManagedObject? {
        
        return try encodable?.save(self)
    }
    
    /// Caches to-one relationship.
    @inline(__always)
    func relationshipFault<T: CoreDataEncodable>(_ encodable: T) throws -> T.ManagedObject {
        
        return try encodable.save(self)
    }
    
    /// Returns faults for to-many relationships.
    @inline(__always)
    func relationshipFault<ManagedObject: Entity>(_ identifiers: Set<Identifier>) throws -> Set<ManagedObject> {
        
        let managedObjects = try identifiers.map { try ManagedObject.cached($0, context: self, returnsObjectsAsFaults: true, includesSubentities: true) }
        
        return Set(managedObjects)
    }
    
    /// Returns faults for to-one relationship.
    @inline(__always)
    func relationshipFault<ManagedObject: Entity>(_ identifier: Identifier?) throws -> ManagedObject? {
        
        guard let identifier = identifier
            else { return nil }
        
        return try ManagedObject.cached(identifier, context: self, returnsObjectsAsFaults: true, includesSubentities: true)
    }
    
    /// Returns faults for to-one relationship.
    @inline(__always)
    func relationshipFault<ManagedObject: Entity>(_ identifier: Identifier) throws -> ManagedObject {
        
        return try ManagedObject.cached(identifier, context: self, returnsObjectsAsFaults: true, includesSubentities: true)
    }
    
    /// Returns managed object for fault value type.
    @inline(__always)
    func relationshipFault<Encodable: Unique>(_ fault: Fault<Encodable>) throws -> Encodable.ManagedObject
        where Encodable: CoreDataEncodable, Encodable.ManagedObject: Entity {
        
        switch fault {
            
        case let .identifier(identifier):
            
            return try Encodable.ManagedObject.cached(identifier,
                                                      context: self,
                                                      returnsObjectsAsFaults: true,
                                                      includesSubentities: true)
            
        case let .value(value):
            
            return try value.save(self)
        }
    }
}
