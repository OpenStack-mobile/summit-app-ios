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
        
        guard fetchRequest.resultType == NSFetchRequestResultType(rawValue: 0x00)
            else { fatalError("Method only supports fetch requests with NSFetchRequestManagedObjectResultType") }
        
        let managedObjects = try self.executeFetchRequest(fetchRequest) as! [T.ManagedObject]
        
        let decodables = managedObjects.map { (element) -> T in T.init(managedObject: element) }
        
        return decodables
    }
}

public extension CoreDataDecodable {
    
    static func from<C: CollectionType where C.Generator.Element == ManagedObject>(managedObjects: C) -> [Self] {
        
        return managedObjects.map { (managedObject) in return self.init(managedObject: managedObject) }
    }
}
