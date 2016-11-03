//
//  VenueRoomManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData

public final class VenueRoomManagedObject: LocationManagedObject {
    
    @NSManaged public var capacity: NSNumber?
    
    @NSManaged public var venue: VenueManagedObject
    
    @NSManaged public var floor: VenueFloorManagedObject?
}

extension VenueRoom: CoreDataDecodable {
    
    public init(managedObject: VenueRoomManagedObject) {
        
        self.identifier = managedObject.identifier
        self.name = managedObject.name
        self.capacity = managedObject.capacity?.integerValue
        self.descriptionText = managedObject.descriptionText
        self.venue = managedObject.venue.identifier
        self.floor = managedObject.floor?.identifier
    }
}

extension VenueRoom: CoreDataEncodable {
    
    public func save(context: NSManagedObjectContext) throws -> VenueRoomManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.name = name
        managedObject.descriptionText = descriptionText
        managedObject.capacity = capacity != nil ? NSNumber(int: Int32(capacity!)) : nil
        managedObject.venue = try context.relationshipFault(venue)
        managedObject.floor = try context.relationshipFault(floor)
        
        managedObject.didCache()
        
        return managedObject
    }
}
