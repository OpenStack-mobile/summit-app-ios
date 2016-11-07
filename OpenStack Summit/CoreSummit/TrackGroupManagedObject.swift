//
//  TrackGroupManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData

public final class TrackGroupManagedObject: Entity {
    
    @NSManaged public var name: String
    
    @NSManaged public var descriptionText: String?
    
    @NSManaged public var color: String
    
    @NSManaged public var tracks: Set<TrackManagedObject>
}

// MARK: - Encoding

extension TrackGroup: CoreDataDecodable {
    
    public init(managedObject: TrackGroupManagedObject) {
        
        self.identifier = managedObject.identifier
        self.name = managedObject.name
        self.descriptionText = managedObject.descriptionText
        self.color = managedObject.color
        self.tracks = managedObject.tracks.identifiers
    }
}

extension TrackGroup: CoreDataEncodable {
    
    public func save(context: NSManagedObjectContext) throws -> TrackGroupManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.name = name
        managedObject.descriptionText = descriptionText
        managedObject.color = color
        managedObject.tracks = try context.relationshipFault(tracks)
        
        managedObject.didCache()
        
        return managedObject
    }
}

// MARK: - Fetches

public extension TrackGroupManagedObject {
    
    static var sortDescriptors: [NSSortDescriptor] {
        
        return [NSSortDescriptor(key: "name", ascending: true)]
    }
}

public extension TrackGroup {
    
    /// Fetch all track groups that have some event associated with them.
    static func scheduled(context: NSManagedObjectContext) throws -> [TrackGroup] {
        
        let predicate = NSPredicate(format: "tracks.presentations.@count > 0")
        
        return try TrackGroup.from(managedObjects: context.managedObjects(ManagedObject.self, predicate: predicate, sortDescriptors: ManagedObject.sortDescriptors))
    }
}
