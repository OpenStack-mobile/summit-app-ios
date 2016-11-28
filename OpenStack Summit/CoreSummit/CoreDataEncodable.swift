//
//  Encode.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData

/// Specifies how a type can be encoded to be stored with Core Data.
public protocol CoreDataEncodable {
    
    associatedtype ManagedObject: NSManagedObject
    
    func save(context: NSManagedObjectContext) throws -> ManagedObject
}

public extension CollectionType where Generator.Element: CoreDataEncodable {
    
    func save(context: NSManagedObjectContext) throws -> Set<Self.Generator.Element.ManagedObject> {
        
        var managedObjects = ContiguousArray<Generator.Element.ManagedObject>()
        managedObjects.reserveCapacity(numericCast(self.count))
        
        for element in self {
            
            let managedObject = try element.save(context)
            
            managedObjects.append(managedObject)
        }
        
        return Set(managedObjects)
    }
}