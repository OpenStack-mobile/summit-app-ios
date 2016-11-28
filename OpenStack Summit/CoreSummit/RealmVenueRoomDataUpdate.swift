//
//  RealmVenueRoomDataUpdate.swift
//  OpenStack Summit
//
//  Created by Gabriel Horacio Cutrini on 10/24/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//


extension VenueRoomDataUpdate: RealmEncodable {
    
    public func save(realm: Realm) -> RealmVenueRoom {
        
        let realmEntity = RealmType.cached(identifier, realm: realm)
        
        realmEntity.name = name
        realmEntity.locationDescription = descriptionText ?? ""
        realmEntity.venue = RealmVenue.cached(venue, realm: realm)
        realmEntity.floor = floor.save(realm)
        realmEntity.capacity = capacity ?? 0
        
        return realmEntity
    }
}
