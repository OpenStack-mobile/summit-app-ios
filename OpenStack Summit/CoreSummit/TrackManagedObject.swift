//
//  TrackManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData

public final class TrackManagedObject: Entity {
    
    @NSManaged public var name: String
    
    @NSManaged public var groups: Set<TrackGroupManagedObject>
    
    // Inverse Relationships
    
    @NSManaged public var presentations: Set<PresentationManagedObject>
}

// MARK: - Encoding

extension Track: CoreDataDecodable {
    
    public init(managedObject: TrackManagedObject) {
        
        self.identifier = managedObject.identifier
        self.name = managedObject.name
        self.groups = managedObject.groups.identifiers
    }
}

extension Track: CoreDataEncodable {
    
    public func save(context: NSManagedObjectContext) throws -> TrackManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.name = name
        managedObject.groups = try context.relationshipFault(groups)
        
        managedObject.didCache()
        
        return managedObject
    }
}

extension MemberResponse.Track: CoreDataEncodable {
    
    public func save(context: NSManagedObjectContext) throws -> TrackManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.name = name
        managedObject.groups = try context.relationshipFault(Set(groups))
        
        managedObject.didCache()
        
        return managedObject
    }
}

// MARK: - Fetches

public extension TrackManagedObject {
    
    static var sortDescriptors: [NSSortDescriptor] {
        
        return [NSSortDescriptor(key: "name", ascending: true)]
    }
}

public extension Track {
    
    static func search(searchTerm: String, context: NSManagedObjectContext) throws -> [Track] {
        
        let predicate = NSPredicate(format: "name CONTAINS[c] %@", searchTerm)
        
        let managedObjects = try context.managedObjects(TrackManagedObject.self, predicate: predicate, sortDescriptors: TrackManagedObject.sortDescriptors)
        
        return Track.from(managedObjects: managedObjects)
    }
    
    /// Get scheduled tracks that belong to track groups.
    static func `for`(groups trackGroups: [Identifier], context: NSManagedObjectContext) throws -> [Track] {
        
        let predicate: NSPredicate
        
        let scheduledTracksPredicate = NSPredicate(format: "events.@count > 0")
        
        // optionally filter for track groups
        if trackGroups.isEmpty == false {
            
            let trackGroupIdentifiers = trackGroups.map { NSNumber(longLong: Int64($0)) }
            
            let trackGroupsPredicate = NSPredicate(format: "ANY groups.id IN %@", [trackGroupIdentifiers])
            
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [scheduledTracksPredicate, trackGroupsPredicate])
            
        } else {
            
            predicate = scheduledTracksPredicate
        }
        
        return try context.managedObjects(Track.self, predicate: predicate, sortDescriptors: ManagedObject.sortDescriptors)
    }
}

