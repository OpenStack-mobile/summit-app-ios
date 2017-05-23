//
//  Decode.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData
import Predicate

/// Specifies how a type can be decoded from Core Data.
public protocol CoreDataDecodable {
    
    associatedtype ManagedObject: NSManagedObject
    
    init(managedObject: ManagedObject)
}

public extension NSManagedObjectContext {
    
    /// Executes a fetch request and returns ```CoreDataDecodable``` types.
    func fetch<T: CoreDataDecodable>(_ fetchRequest: NSFetchRequest<T.ManagedObject>) throws -> [T] {
        
        guard fetchRequest.resultType == NSFetchRequestResultType()
            else { fatalError("Method only supports fetch requests with NSFetchRequestManagedObjectResultType") }
        
        let managedObjects = try self.fetch(fetchRequest)
        
        let decodables = managedObjects.map { T.init(managedObject: $0) }
        
        return decodables
    }
    
    @inline(__always)
    func managedObjects<T: CoreDataDecodable>(_ decodableType: T.Type,
                        predicate: NSPredicate? = nil,
                        sortDescriptors: [NSSortDescriptor] = [],
                        limit: Int = 0) throws -> [T] {
        
        let results = try self.managedObjects(decodableType.ManagedObject.self,
                                              predicate: predicate,
                                              sortDescriptors: sortDescriptors,
                                              limit: limit)
        
        return T.from(managedObjects: results)
    }
    
    @inline(__always)
    func managedObjects<T: CoreDataDecodable>(_ decodableType: T.Type,
                        predicate: Predicate,
                        sortDescriptors: [NSSortDescriptor] = [],
                        limit: Int = 0) throws -> [T] {
        
        let results = try self.managedObjects(decodableType.ManagedObject.self,
                                              predicate: predicate.toFoundation(),
                                              sortDescriptors: sortDescriptors,
                                              limit: limit)
        
        return T.from(managedObjects: results)
    }
}

/* Swift 3 compile error
@available(OSX 10.12, *)
public extension NSFetchedResultsController {
    
    convenience init <T: CoreDataDecodable>
        (_ decodable: T.Type,
         delegate: NSFetchedResultsControllerDelegate? = nil,
         predicate: NSPredicate? = nil,
         sortDescriptors: [NSSortDescriptor] = [],
         sectionNameKeyPath: String? = nil,
         context: NSManagedObjectContext) {
        
        let managedObjectType = T.ManagedObject.self
        
        let entity = context.persistentStoreCoordinator!.managedObjectModel[managedObjectType]!
        
        let fetchRequest = NSFetchRequest<T.ManagedObject>(entityName: entity.name!)
        
        fetchRequest.predicate = predicate
        
        fetchRequest.sortDescriptors = sortDescriptors
        
        self.init(fetchRequest: fetchRequest as! NSFetchRequest<_>,
                  managedObjectContext: context, sectionNameKeyPath: sectionNameKeyPath, cacheName: nil)
        
        self.delegate = delegate
    }
}
 */

public func NSFetchedResultsController <T: CoreDataDecodable>
    (_ decodable: T.Type,
     delegate: NSFetchedResultsControllerDelegate? = nil,
     predicate: Predicate? = nil,
     sortDescriptors: [NSSortDescriptor] = [],
     sectionNameKeyPath: String? = nil,
     context: NSManagedObjectContext) -> NSFetchedResultsController<T.ManagedObject> {
    
    let managedObjectType = T.ManagedObject.self
    
    let entity = context.persistentStoreCoordinator!.managedObjectModel[managedObjectType]!
    
    let fetchRequest = NSFetchRequest<T.ManagedObject>(entityName: entity.name!)
    
    fetchRequest.predicate = predicate?.toFoundation()
    
    fetchRequest.sortDescriptors = sortDescriptors
    
    let fetchedResultsController = CoreData.NSFetchedResultsController.init(fetchRequest: fetchRequest,
                                                                            managedObjectContext: context,
                                                                            sectionNameKeyPath: sectionNameKeyPath,
                                                                            cacheName: nil)
    
    fetchedResultsController.delegate = delegate
    
    return fetchedResultsController
}

public extension CoreDataDecodable {
    
    static func from <C: RandomAccessCollection> (managedObjects: C) -> [Self]
        where C.Iterator.Element == ManagedObject {
        
        return managedObjects.map { self.init(managedObject: $0) }
    }
}

public extension CoreDataDecodable where Self: Hashable {
    
    static func from(managedObjects: Set<ManagedObject>) -> Set<Self> {
        
        return Set(managedObjects.map({ self.init(managedObject: $0) }))
    }
}
