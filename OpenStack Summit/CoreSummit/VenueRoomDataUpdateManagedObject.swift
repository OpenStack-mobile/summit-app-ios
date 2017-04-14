//
//  VenueRoomDataUpdateManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/3/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData

extension VenueRoom.DataUpdate: CoreDataEncodable {
    
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
