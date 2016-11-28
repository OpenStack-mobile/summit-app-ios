//
//  CompanyManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData

public final class CompanyManagedObject: Entity {
        
    @NSManaged public var name: String
    
    // Inverse Relationships
    
    @NSManaged public var events: Set<EventManagedObject>
    
    @NSManaged public var summits: Set<SummitManagedObject>
}

extension Company: CoreDataDecodable {
    
    public init(managedObject: CompanyManagedObject) {
        
        self.identifier = managedObject.identifier
        self.name = managedObject.name
    }
}

extension Company: CoreDataEncodable {
    
    public func save(context: NSManagedObjectContext) throws -> CompanyManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.name = name
        
        managedObject.didCache()
        
        return managedObject
    }
}
