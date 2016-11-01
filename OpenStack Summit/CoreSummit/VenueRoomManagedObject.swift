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
    
    @NSManaged public var capacity: Int32
    
    @NSManaged public var venue: VenueManagedObject
    
    @NSManaged public var floor: VenueFloorManagedObject
}

extension VenueRoom: CoreDataDecodable {
    
    public init(managedObject: VenueRoomManagedObject) {
        
        self.identifier = Int(managedObject.id)
        self.name = managedObject.name
        self.descriptionText = managedObject.descriptionText
        self.venue = Int(managedObject.venue.id)
        self.floor = Int(managedObject.floor.id)
    }
}

extension VenueRoom: CoreDataEncodable {
    
    public func save(context: NSManagedObjectContext) throws -> VenueRoomManagedObject {
        
        let managedObject = try ManagedObject.cached(identifier, context: context, returnsObjectsAsFaults: true, includesSubentities: false)
        
        managedObject.name = name
        managedObject.descriptionText = descriptionText
        managedObject.venue = try VenueManagedObject.cached(venue, context: context, returnsObjectsAsFaults: true, includesSubentities: false)
        managedObject.floor = try VenueFloorManagedObject.cached(floor, context: context, returnsObjectsAsFaults: true, includesSubentities: false)
        
        return managedObject
    }
}
