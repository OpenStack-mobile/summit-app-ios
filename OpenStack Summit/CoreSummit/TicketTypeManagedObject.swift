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
    
    @NSManaged public var allowedSummitTypes: Set<SummitTypeManagedObject>
}

extension TicketType: CoreDataDecodable {
    
    public init(managedObject: TicketTypeManagedObject) {
        
        self.identifier = managedObject.identifier
        self.name = managedObject.name
        self.descriptionText = managedObject.descriptionText
        self.allowedSummitTypes = managedObject.allowedSummitTypes.identifiers
    }
}

extension TicketType: CoreDataEncodable {
    
    public func save(context: NSManagedObjectContext) throws -> TicketTypeManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.name = name
        managedObject.descriptionText = descriptionText
        managedObject.allowedSummitTypes = try context.relationshipFault(allowedSummitTypes)
        
        managedObject.didCache()
        
        return managedObject
    }
}
