//
//  VenueRoomManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData
import Predicate

public final class VenueRoomManagedObject: LocationManagedObject {
    
    @NSManaged public var capacity: NSNumber?
    
    @NSManaged public var venue: VenueManagedObject
    
    @NSManaged public var floor: VenueFloorManagedObject?
}

extension VenueRoom: CoreDataDecodable {
    
    public init(managedObject: VenueRoomManagedObject) {
        
        self.identifier = managedObject.id
        self.name = managedObject.name
        self.capacity = managedObject.capacity?.intValue
        self.descriptionText = managedObject.descriptionText
        self.venue = managedObject.venue.id
        self.floor = managedObject.floor?.id
    }
}

extension VenueRoom: CoreDataEncodable {
    
    public func save(_ context: NSManagedObjectContext) throws -> VenueRoomManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.name = name
        managedObject.descriptionText = descriptionText
        managedObject.capacity = capacity != nil ? NSNumber(value: Int32(capacity!) as Int32) : nil
        managedObject.venue = try context.relationshipFault(venue)
        managedObject.floor = try context.relationshipFault(floor)
        
        managedObject.didCache()
        
        return managedObject
    }
}

// MARK - Fetches

public extension VenueRoomManagedObject {
    
    static var sortDescriptors: [NSSortDescriptor] {
        
        return [NSSortDescriptor(key: #keyPath(VenueRoomManagedObject.name), ascending: true)]
    }
}

public extension VenueRoom {
    
    /// Fetch all rooms that have some event associated with them.
    static func scheduled(for summit: Identifier, context: NSManagedObjectContext) throws -> [VenueRoom] {
        
        // NSPredicate(format: "location != nil AND summit == %@", summitManagedObject))
        let eventsPredicate: Predicate = .keyPath(#keyPath(EventManagedObject.location)) != .value(.null)
            && #keyPath(EventManagedObject.summit.id) == summit
        
        let events = try context.managedObjects(EventManagedObject.self, predicate: eventsPredicate)
        
        let locations = Set(events.compactMap({ $0.location }))
            .sorted(by: { $0.name < $1.name })
        
        var rooms = [VenueRoomManagedObject]()
        
        for location in locations {
            
            if let room = location as? VenueRoomManagedObject {
                
                rooms.append(room)
            }
        }
        
        return VenueRoom.from(managedObjects: rooms)
    }
}

