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
    
    @NSManaged public var number: Int16
    
    @NSManaged public var imageURL: String?
    
    @NSManaged public var venue: VenueManagedObject
    
    @NSManaged public var rooms: Set<VenueRoomManagedObject>
}

extension VenueFloor: CoreDataDecodable {
    
    public init(managedObject: VenueFloorManagedObject) {
        
        self.identifier = managedObject.id
        self.name = managedObject.name
        self.descriptionText = managedObject.descriptionText
        self.number = managedObject.number
        self.image = URL(string: managedObject.imageURL ?? "")
        self.venue = managedObject.venue.id
        self.rooms = managedObject.rooms.identifiers
    }
}

extension VenueFloor: CoreDataEncodable {
    
    public func save(_ context: NSManagedObjectContext) throws -> VenueFloorManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.name = name
        managedObject.descriptionText = descriptionText
        managedObject.number = number
        managedObject.imageURL = image?.absoluteString
        managedObject.venue = try context.relationshipFault(venue)
        managedObject.rooms = try context.relationshipFault(rooms)
        
        managedObject.didCache()
        
        return managedObject
    }
}
