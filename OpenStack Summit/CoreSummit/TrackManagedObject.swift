//
//  TrackManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData
import Predicate

public final class TrackManagedObject: Entity {
    
    @NSManaged public var name: String
    
    @NSManaged public var groups: Set<TrackGroupManagedObject>
    
    // Inverse Relationships
    
    @NSManaged public var events: Set<EventManagedObject>
    
    @NSManaged public var summits: Set<SummitManagedObject>
}

// MARK: - Encoding

extension Track: CoreDataDecodable {
    
    public init(managedObject: TrackManagedObject) {
        
        self.identifier = managedObject.id
        self.name = managedObject.name
        self.groups = managedObject.groups.identifiers
    }
}

extension Track: CoreDataEncodable {
    
    public func save(_ context: NSManagedObjectContext) throws -> TrackManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.name = name
        managedObject.groups = try context.relationshipFault(groups)
        
        managedObject.didCache()
        
        return managedObject
    }
}

extension MemberResponse.Track: CoreDataEncodable {
    
    public func save(_ context: NSManagedObjectContext) throws -> TrackManagedObject {
        
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
        
        return [NSSortDescriptor(key: #keyPath(TrackManagedObject.name), ascending: true)]
    }
}

public extension Track {
    
    static func search(_ searchTerm: String, context: NSManagedObjectContext) throws -> [Track] {
        
        let predicate: Predicate = (#keyPath(TrackManagedObject.name)).compare(.contains, [.caseInsensitive], .value(.string(searchTerm)))
        
        return try Track.filter(predicate,
                                sort: ManagedObject.sortDescriptors,
                                context: context)
    }
    
    /// Get scheduled tracks that belong to track groups.
    static func `for`(groups trackGroups: [Identifier] = [], context: NSManagedObjectContext) throws -> [Track] {
        
        let predicate: Predicate
        
        // let scheduledTracksPredicate = Predicate(format: "events.@count > 0")
        let scheduledTracks: Predicate = #keyPath(TrackManagedObject.events) + ".@count" > 0
        
        // optionally filter for track groups
        if trackGroups.isEmpty == false {
            
            //let trackGroupsPredicate = NSPredicate(format: "ANY groups.id IN %@", [trackGroups])
            let trackGroupsPredicate: Predicate = (#keyPath(TrackManagedObject.groups.id)).in(trackGroups)
            
            predicate = .compound(.and([scheduledTracks, trackGroupsPredicate]))
            
        } else {
            
            predicate = scheduledTracks
        }
        
        return try context.managedObjects(self, predicate: predicate, sortDescriptors: ManagedObject.sortDescriptors)
    }
}

