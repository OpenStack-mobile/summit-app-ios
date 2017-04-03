//
//  Decode.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData

/// Specifies how a type can be decoded from Core Data.
public protocol CoreDataDecodable {
    
    associatedtype ManagedObject: NSManagedObject
    
    init(managedObject: ManagedObject)
}

public extension NSManagedObjectContext {
    
    /// Executes a fetch request and returns ```CoreDataDecodable``` types.
    func fetch<T: CoreDataDecodable>(fetchRequest: NSFetchRequest) throws -> [T] {
        
        guard fetchRequest.resultType == .ManagedObjectResultType
            else { fatalError("Method only supports fetch requests with NSFetchRequestManagedObjectResultType") }
        
        let managedObjects = try self.executeFetchRequest(fetchRequest) as! [T.ManagedObject]
        
        let decodables = managedObjects.map { T.init(managedObject: $0) }
        
        return decodables
    }
    
    @inline(__always)
    func managedObjects<T: CoreDataDecodable>(decodableType: T.Type, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor] = [], limit: Int = 0) throws -> [T] {
        
        let results = try self.managedObjects(decodableType.ManagedObject.self, predicate: predicate, sortDescriptors: sortDescriptors, limit: limit)
        
        return T.from(managedObjects: results)
    }
    
    @inline(__always)
    func managedObjects<T: CoreDataDecodable>(decodableType: T.Type, predicate: Predicate, sortDescriptors: [NSSortDescriptor] = []) throws -> [T] {
        
        let results = try self.managedObjects(decodableType.ManagedObject.self, predicate: predicate.toFoundation(), sortDescriptors: sortDescriptors)
        
        return T.from(managedObjects: results)
    }
}

@available(OSX 10.12, *)
public extension NSFetchedResultsController {
    
    convenience init<T: CoreDataDecodable>(_ decodable: T.Type, delegate: NSFetchedResultsControllerDelegate? = nil, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor] = [], sectionNameKeyPath: String? = nil, context: NSManagedObjectContext) {
        
        let managedObjectType = T.ManagedObject.self
        
        let entity = context.persistentStoreCoordinator!.managedObjectModel[managedObjectType]!
        
        let fetchRequest = NSFetchRequest(entityName: entity.name!)
        
        fetchRequest.predicate = predicate
        
        fetchRequest.sortDescriptors = sortDescriptors
        
        self.init(fetchRequest: fetchRequest, managedObjectContext: context, sectionNameKeyPath: sectionNameKeyPath, cacheName: nil)
        
        self.delegate = delegate
    }
}

public extension CoreDataDecodable {
    
    static func from<C: CollectionType where C.Generator.Element == ManagedObject>(managedObjects managedObjects: C) -> [Self] {
        
        return managedObjects.map { self.init(managedObject: $0) }
    }
}

public extension CoreDataDecodable where Self: Hashable {
    
    static func from(managedObjects managedObjects: Set<ManagedObject>) -> Set<Self> {
        
        return Set(managedObjects.map({ self.init(managedObject: $0) }))
    }
}
