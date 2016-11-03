//
//  LocationManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData

public class LocationManagedObject: Entity {
    
    @NSManaged public var name: String
    
    @NSManaged public var descriptionText: String?
    
    // Inverse Relationships
    
    @NSManaged public var events: Set<EventManagedObject>
    
    @NSManaged public var summits: SummitManagedObject
}

extension Location: CoreDataDecodable {
    
    public init(managedObject: LocationManagedObject) {
        
        if let venueManagedObject = managedObject as? VenueManagedObject {
            
            let venue = Venue(managedObject: venueManagedObject)
            
            self = .venue(venue)
            
            
        } else if let roomManagedObject = managedObject as? VenueRoomManagedObject {
            
            let room = VenueRoom(managedObject: roomManagedObject)
            
            self = .room(room)
            
        } else {
            
            fatalError("Invalid LocationManagedObject: \(managedObject)")
        }
    }
}

extension Location: CoreDataEncodable {
    
    public func save(context: NSManagedObjectContext) throws -> LocationManagedObject {
        
        switch self {
        case let .venue(venue): return try venue.save(context)
        case let .room(room): return try room.save(context)
        }
    }
}
