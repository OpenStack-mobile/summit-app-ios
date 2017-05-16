//
//  SlideManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 5/5/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import CoreData

public final class SlideManagedObject: Entity {
    
    @NSManaged public var name: String
    
    @NSManaged public var descriptionText: String?
    
    @NSManaged public var displayOnSite: Bool
    
    @NSManaged public var featured: Bool
    
    @NSManaged public var order: Int64
    
    @NSManaged public var link: String
    
    @NSManaged public var event: EventManagedObject
}

extension Slide: CoreDataDecodable {
    
    public init(managedObject: SlideManagedObject) {
        
        self.identifier = managedObject.id
        self.name = managedObject.name
        self.descriptionText = managedObject.descriptionText
        self.displayOnSite = managedObject.displayOnSite
        self.featured = managedObject.featured
        self.link = URL(string: managedObject.link)!
        self.event = managedObject.event.id
        self.order = managedObject.order
    }
}

extension Slide: CoreDataEncodable {
    
    public func save(_ context: NSManagedObjectContext) throws -> SlideManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.name = name
        managedObject.descriptionText = descriptionText
        managedObject.displayOnSite = displayOnSite
        managedObject.featured = featured
        managedObject.link = link.absoluteString
        managedObject.order = order
        managedObject.event = try context.relationshipFault(event)
        
        managedObject.didCache()
        
        return managedObject
    }
}
