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
}
