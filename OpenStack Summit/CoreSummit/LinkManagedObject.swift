//
//  LinkManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 5/5/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import CoreData

public final class LinkManagedObject: Entity {
    
    @NSManaged public var name: String
    
    @NSManaged public var descriptionText: String?
    
    @NSManaged public var displayOnSite: Bool
    
    @NSManaged public var featured: Bool
    
    @NSManaged public var order: Int64
    
    @NSManaged public var link: String
    
    @NSManaged public var event: EventManagedObject
}

extension Link: CoreDataDecodable {
    
    public init(managedObject: LinkManagedObject) {
        
        self.identifier = managedObject.identifier
        self.name = managedObject.name
        self.descriptionText = managedObject.descriptionText
        self.displayOnSite = managedObject.displayOnSite
        self.featured = managedObject.featured
        self.link = managedObject.link
        self.event = managedObject.event.identifier
        self.order = Int(managedObject.order)
    }
}

extension Link: CoreDataEncodable {
    
    public func save(context: NSManagedObjectContext) throws -> LinkManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.name = name
        managedObject.descriptionText = descriptionText
        managedObject.displayOnSite = displayOnSite
        managedObject.featured = featured
        managedObject.link = link
        managedObject.order = Int64(order)
        managedObject.event = try context.relationshipFault(event)
        
        managedObject.didCache()
        
        return managedObject
    }
}
