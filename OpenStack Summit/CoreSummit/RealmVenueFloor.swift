//
//  RealmVenueFloor.swift
//  OpenStackSummit
//
//  Created by Gabriel Horacio Cutrini on 10/4/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import RealmSwift

public class RealmVenueFloor: RealmNamed {
    
    public dynamic var descriptionText = ""
    public dynamic var number = 0
    public dynamic var imageURL = ""
    public dynamic var venue: RealmVenue!
    public var rooms = List<RealmVenueRoom>()
}

// MARK: - Encoding

extension VenueFloor: RealmDecodable {
    
    public init(realmEntity: RealmVenueFloor) {
        
        self.identifier = realmEntity.id
        self.name = realmEntity.name
        self.descriptionText = String(realm: realmEntity.descriptionText)
        self.number = realmEntity.number
        self.imageURL = String(realm: realmEntity.imageURL)
        self.venue = realmEntity.venue.id
        self.rooms = realmEntity.rooms.identifiers
    }
}

extension VenueFloor: RealmEncodable {
    
    public func save(realm: Realm) -> RealmVenueFloor {
        
        let realmEntity = RealmType.cached(identifier, realm: realm)
        
        realmEntity.name = name
        realmEntity.descriptionText = descriptionText ?? ""
        realmEntity.number = number ?? 0
        realmEntity.imageURL = imageURL ?? ""
        realmEntity.venue = RealmVenue.cached(venue, realm: realm)
        realmEntity.rooms.replace(with: rooms)
        
        return realmEntity
    }
}
