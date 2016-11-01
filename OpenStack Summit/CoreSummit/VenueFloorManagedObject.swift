//
//  VenueFloorManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData

public final class VenueFloorManagedObject: Entity {
    
    @NSManaged public var name: String
    
    @NSManaged public var descriptionText: String?
    
    @NSManaged public var number: Int32
    
    @NSManaged public var imageURL: String?
    
    @NSManaged public var venue: VenueManagedObject
    
    @NSManaged public var rooms: Set<VenueRoomManagedObject>
}

extension VenueFloor: CoreDataDecodable {
    
    public init(managedObject: VenueFloorManagedObject) {
        
        self.identifier = Int(managedObject.id)
        self.descriptionText = managedObject.descriptionText
        self.number = Int(managedObject.number)
        self.imageURL = managedObject.imageURL
        self.venue = Int(managedObject.venue.id)
        self.rooms = managedObject.rooms.identifiers
    }
}

extension VenueFloor: CoreDataEncodable {
    
    public func save(context: NSManagedObjectContext) throws -> VenueFloorManagedObject {
        
        let managedObject = try ManagedObject.cached(identifier, context: context, returnsObjectsAsFaults: true, includesSubentities: false)
        
        managedObject.descriptionText = descriptionText
        managedObject.number = Int32(number)
        managedObject.imageURL = imageURL
        managedObject.venue = try VenueManagedObject.cached(identifier, context: context, returnsObjectsAsFaults: true, includesSubentities: false)
        
        return managedObject
    }
}
