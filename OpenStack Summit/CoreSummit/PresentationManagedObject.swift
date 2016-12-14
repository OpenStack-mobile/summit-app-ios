//
//  PresentationManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData

public final class PresentationManagedObject: Entity {
    
    @NSManaged public var level: String?
    
    @NSManaged public var track: TrackManagedObject?
    
    @NSManaged public var moderator: SpeakerManagedObject?
    
    @NSManaged public var speakers: Set<SpeakerManagedObject>
}

extension Presentation: CoreDataDecodable {
    
    public init(managedObject: PresentationManagedObject) {
        
        self.identifier = managedObject.identifier
        self.level = managedObject.level != nil ? Level(rawValue: managedObject.level!) : nil
        self.moderator = managedObject.moderator?.identifier
        self.speakers = managedObject.speakers.identifiers
    }
}

extension Presentation: CoreDataEncodable {
    
    public func save(context: NSManagedObjectContext) throws -> PresentationManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.level = level?.rawValue
        managedObject.moderator = try context.relationshipFault(moderator)
        managedObject.speakers = try context.relationshipFault(speakers)
        
        managedObject.didCache()
        
        return managedObject
    }
}
