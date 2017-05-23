//
//  AffiliationOrganizationManagedObject.swift
//  OpenStack Summit
//
//  Created by Gabriel Horacio Cutrini on 3/24/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import CoreData

public final class AffiliationOrganizationManagedObject: Entity {
    
    @NSManaged public var name: String
}

extension AffiliationOrganization: CoreDataDecodable {
    
    public init(managedObject: AffiliationOrganizationManagedObject) {
        
        self.identifier = managedObject.id
        self.name = managedObject.name
    }
}

extension AffiliationOrganization: CoreDataEncodable {
    
    public func save(_ context: NSManagedObjectContext) throws -> AffiliationOrganizationManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.name = name
        
        managedObject.didCache()
        
        return managedObject
    }
}
