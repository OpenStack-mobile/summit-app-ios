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
    
    @NSManaged public final var name: String
    
    @NSManaged public final var descriptionText: String?
    
    // Inverse Relationships
    
    @NSManaged public final var events: Set<EventManagedObject>
    
    @NSManaged public final var summits: SummitManagedObject
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
