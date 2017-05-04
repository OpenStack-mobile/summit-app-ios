//
//  CoreDataExtensions.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData

public extension NSManagedObjectContext {
    
    /// Wraps the block to allow for error throwing.
    @available(OSX 10.7, *)
    func performErrorBlockAndWait<T>(block: () throws -> T) throws -> T {
        
        var blockError: ErrorType?
        
        var value: T!
        
        self.performBlockAndWait {
            
            do { value = try block() }
            
            catch { blockError = error }
            
            return
        }
        
        if let error = blockError {
            
            throw error
        }
        
        return value
    }
    
    @inline(__always)
    func find<T: NSManagedObject, V: AnyObject>(entity: NSEntityDescription, resourceID: V, identifierProperty: String, returnsObjectsAsFaults: Bool = true, includesSubentities: Bool = true) throws -> T? {
        
        // get cached resource...
        
        let fetchRequest = NSFetchRequest(entityName: entity.name!)
        
        fetchRequest.fetchLimit = 1
        
        fetchRequest.includesSubentities = includesSubentities
        
        fetchRequest.returnsObjectsAsFaults = returnsObjectsAsFaults
        
        // create predicate
        
        fetchRequest.predicate = NSComparisonPredicate(leftExpression: NSExpression(forKeyPath: identifierProperty), rightExpression: NSExpression(forConstantValue: resourceID), modifier: NSComparisonPredicateModifier.DirectPredicateModifier, type: NSPredicateOperatorType.EqualToPredicateOperatorType, options: NSComparisonPredicateOptions.NormalizedPredicateOption)
        
        // fetch
        
        return try self.executeFetchRequest(fetchRequest).first as! T?
    }
    
    @inline(__always)
    func findOrCreate<T: NSManagedObject, V: AnyObject>(entity: NSEntityDescription, resourceID: V, identifierProperty: String, returnsObjectsAsFaults: Bool = true, includesSubentities: Bool = true) throws -> T {
        
        let resource: T
        
        if let firstResult = try find(entity, resourceID: resourceID, identifierProperty: identifierProperty, returnsObjectsAsFaults: returnsObjectsAsFaults, includesSubentities: includesSubentities) as T? {
            
            resource = firstResult
        }
            
        // create cached resource if not found
        else {
            
            // create a new entity
            let newManagedObject = NSEntityDescription.insertNewObjectForEntityForName(entity.name!, inManagedObjectContext: self)
            
            // set resource ID
            (newManagedObject).setValue(resourceID, forKey: identifierProperty)
            
            resource = newManagedObject as! T
        }
        
        return resource
    }
    
    @inline(__always)
    func managedObjects<ManagedObject: NSManagedObject>(managedObjectType: ManagedObject.Type, predicate: NSPredicate? = nil, sortDescriptors: [NSSortDescriptor] = [], limit: Int = 0) throws -> [ManagedObject] {
        
        let entity = self.persistentStoreCoordinator!.managedObjectModel[managedObjectType]!
        
        let fetchRequest = NSFetchRequest(entityName: entity.name!)
        
        fetchRequest.predicate = predicate
        
        fetchRequest.sortDescriptors = sortDescriptors
        
        fetchRequest.fetchLimit = limit
        
        return try self.executeFetchRequest(fetchRequest) as! [ManagedObject]
    }
    
    @inline(__always)
    func managedObjects<ManagedObject: NSManagedObject>(managedObjectType: ManagedObject.Type, predicate: Predicate, sortDescriptors: [NSSortDescriptor] = []) throws -> [ManagedObject] {
        
        return try managedObjects(managedObjectType, predicate: predicate.toFoundation(), sortDescriptors: sortDescriptors)
    }
    
    @inline(__always)
    func count<ManagedObject: NSManagedObject>(managedObjectType: ManagedObject.Type, predicate: NSPredicate? = nil) throws -> Int {
        
        let entity = self.persistentStoreCoordinator!.managedObjectModel[managedObjectType]!
        
        let fetchRequest = NSFetchRequest(entityName: entity.name!)
        
        fetchRequest.resultType = .CountResultType
        
        fetchRequest.predicate = predicate
        
        return (try self.executeFetchRequest(fetchRequest) as! [NSNumber]).first!.integerValue
    }
    
    @inline(__always)
    func count<ManagedObject: NSManagedObject>(managedObjectType: ManagedObject.Type, predicate: CoreSummit.Predicate) throws -> Int {
        
        return try count(managedObjectType, predicate: predicate.toFoundation())
    }
    
    /// Save and attempt to recover from validation errors
    func validateAndSave(fileName: String = #file, _ lineNumber: Int = #line) throws {
        
        do { try save() }
        
        catch {
            
            // attempt to get invalid managed objects
            let invalidObjects = (error as NSError).invalidManagedObjects
            
            guard invalidObjects.isEmpty == false
                else { throw error }
            
            // delete invalid objects
            invalidObjects.forEach { self.deleteObject($0) }
            
            #if DEBUG
            print("CoreData validation error at \(fileName):\(lineNumber)\n\(error)")
            #endif
            
            // try to save again (and catch more validation errors)
            try validateAndSave(fileName, lineNumber)
        }
    }
}

public extension NSManagedObjectModel {
    
    subscript(managedObjectType: NSManagedObject.Type) -> NSEntityDescription? {
        
        // search for entity with class name
        
        let className = NSStringFromClass(managedObjectType)
        
        return self.entities.firstMatching { $0.managedObjectClassName == className }
    }
}

public extension NSError {
    
    var invalidManagedObjects: Set<NSManagedObject> {
        
        var invalidObjects = Set<NSManagedObject>()
        
        if let errors = userInfo[NSDetailedErrorsKey] as? [NSError] {
            
            errors.forEach { $0.invalidManagedObjects.forEach { invalidObjects.insert($0) } }
            
        } else if let invalidObject = userInfo[NSValidationObjectErrorKey] as? NSManagedObject {
            
            invalidObjects.insert(invalidObject)
        }
        
        return invalidObjects
    }
}
