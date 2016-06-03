//
//  RealmVenueRoom.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import RealmSwift
import Realm

public class RealmVenueRoom: RealmLocation {
    
    public dynamic var capacity = 0
    public dynamic var venue: RealmVenue!
    
    public var events: [RealmSummitEvent] {
        
        return linkingObjects(RealmSummitEvent.self, forProperty: "venueRoom")
    }
}

// MARK: - Encoding

extension VenueRoom: RealmDecodable {
    
    public init(realmEntity: RealmVenueRoom) {
        
        self.identifier = realmEntity.id
        self.name = realmEntity.name
        self.descriptionText = realmEntity.locationDescription
        self.capacity = realmEntity.capacity
        self.venueIdentifier = realmEntity.venue.id
    }
}