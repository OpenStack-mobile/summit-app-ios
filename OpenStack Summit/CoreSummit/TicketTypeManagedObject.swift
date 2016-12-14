//
//  TicketTypeManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData

public final class TicketTypeManagedObject: Entity {
    
    @NSManaged public var name: String
    
    @NSManaged public var descriptionText: String?
}

extension TicketType: CoreDataDecodable {
    
    public init(managedObject: TicketTypeManagedObject) {
        
        self.identifier = managedObject.identifier
        self.name = managedObject.name
        self.descriptionText = managedObject.descriptionText
    }
}

extension TicketType: CoreDataEncodable {
    
    public func save(context: NSManagedObjectContext) throws -> TicketTypeManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.name = name
        managedObject.descriptionText = descriptionText
        
        managedObject.didCache()
        
        return managedObject
    }
}
