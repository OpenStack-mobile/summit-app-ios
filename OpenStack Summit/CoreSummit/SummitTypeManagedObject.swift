//
//  SummitTypeManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData

public final class SummitTypeManagedObject: Entity {
    
    @NSManaged public var name: String
    
    @NSManaged public var color: String
}

extension SummitType: CoreDataDecodable {
    
    public init(managedObject: SummitTypeManagedObject) {
        
        self.identifier = managedObject.id
        self.name = managedObject.name
        self.color = managedObject.color
    }
}

extension SummitType: CoreDataEncodable {
    
    public func save(_ context: NSManagedObjectContext) throws -> SummitTypeManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.name = name
        managedObject.color = color
        
        managedObject.didCache()
        
        return managedObject
    }
}
