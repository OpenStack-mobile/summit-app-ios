//
//  VideoManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData

public final class VideoManagedObject: Entity {
    
    @NSManaged public var name: String
    
    @NSManaged public var descriptionText: String?
    
    @NSManaged public var displayOnSite: Bool
    
    @NSManaged public var featured: Bool
    
    @NSManaged public var youtube: String
    
    // Inverse Relationships
    
    @NSManaged public var event: EventManagedObject
    
}

extension Video: CoreDataDecodable {
    
    public init(managedObject: VideoManagedObject) {
        
        self.identifier = managedObject.identifier
        self.name = managedObject.name
        self.descriptionText = managedObject.descriptionText
        self.displayOnSite = managedObject.displayOnSite
        self.featured = managedObject.featured
        self.youtube = managedObject.youtube
    }
}

extension Video: CoreDataEncodable {
    
    public func save(context: NSManagedObjectContext) throws -> VideoManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.name = name
        managedObject.descriptionText = descriptionText
        managedObject.displayOnSite = displayOnSite
        managedObject.featured = featured
        managedObject.youtube = youtube
        
        managedObject.didCache()
        
        return managedObject
    }
}
