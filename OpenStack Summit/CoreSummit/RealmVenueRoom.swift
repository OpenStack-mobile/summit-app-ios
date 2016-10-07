//
//  RealmVenueRoom.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import RealmSwift

public class RealmVenueRoom: RealmLocation {
    
    public dynamic var capacity = 0
    public dynamic var venue: RealmVenue!
    public dynamic var floor: RealmVenueFloor!
    /*
    public var events: [RealmSummitEvent] {
        
        return linkingObjects(RealmSummitEvent.self, forProperty: "venueRoom")
    }*/
}

// MARK: - Encoding

extension VenueRoom: RealmDecodable {
    
    public init(realmEntity: RealmVenueRoom) {
        
        self.identifier = realmEntity.id
        self.name = realmEntity.name
        self.descriptionText = String(realm: realmEntity.locationDescription)
        self.venue = realmEntity.venue.id
        self.floor = realmEntity.floor.id
        
        if realmEntity.capacity == 0 {
            
            self.capacity = nil
            
        } else {
         
            self.capacity = realmEntity.capacity
        }
    }
}

extension VenueRoom: RealmEncodable {
    
    public func save(realm: Realm) -> RealmVenueRoom {
        
        let realmEntity = RealmType.cached(identifier, realm: realm)
        
        realmEntity.name = name
        realmEntity.locationDescription = descriptionText ?? ""
        realmEntity.venue = RealmVenue.cached(venue, realm: realm)
        realmEntity.floor = RealmVenueFloor.cached(floor, realm: realm)
        realmEntity.capacity = capacity ?? 0
        
        return realmEntity
    }
}
