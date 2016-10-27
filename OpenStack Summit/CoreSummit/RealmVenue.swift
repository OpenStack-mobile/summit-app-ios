//
//  RealmVenue.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import RealmSwift

public class RealmVenue: RealmLocation {
    
    public dynamic var address = ""
    public dynamic var city = ""
    public dynamic var zipCode = ""
    public dynamic var state = ""
    public dynamic var country = ""
    public dynamic var lat = ""
    public dynamic var long = ""
    public dynamic var isInternal = true
    public dynamic var venueClassName = ""
    public let maps = List<RealmImage>()
    public let images = List<RealmImage>()
    public let floors = List<RealmVenueFloor>()
}

// MARK: - Encoding

extension Venue: RealmDecodable {
    
    public init(realmEntity: RealmVenue) {
        
        self.identifier = realmEntity.id
        self.type = ClassName(rawValue: realmEntity.venueClassName)!
        self.name = realmEntity.name
        self.descriptionText = String(realm: realmEntity.locationDescription)
        self.address = String(realm: realmEntity.address)
        self.city = String(realm: realmEntity.city)
        self.zipCode = String(realm: realmEntity.zipCode)
        self.state = String(realm: realmEntity.state)
        self.country = realmEntity.country
        self.latitude = String(realm: realmEntity.lat)
        self.longitude = String(realm: realmEntity.long)
        self.locationType = realmEntity.isInternal ? .Internal : .External
        self.maps = Image.from(realm: realmEntity.maps)
        self.images = Image.from(realm: realmEntity.images)
        self.floors = VenueFloor.from(realm: realmEntity.floors)
    }
}

extension Venue: RealmEncodable {
    
    public func save(realm: Realm) -> RealmVenue {
        
        let realmEntity = RealmType.cached(identifier, realm: realm)
        
        realmEntity.venueClassName = type.rawValue
        realmEntity.name = name
        realmEntity.locationDescription = descriptionText ?? ""
        realmEntity.country = country
        realmEntity.address = address ?? ""
        realmEntity.city = city ?? ""
        realmEntity.zipCode = zipCode ?? ""
        realmEntity.state = state ?? ""
        realmEntity.lat = latitude ?? ""
        realmEntity.long = longitude ?? ""
        realmEntity.isInternal = locationType == .Internal
        realmEntity.maps.replace(with: maps)
        realmEntity.images.replace(with: images)
        realmEntity.floors.replace(with: floors)
        
        return realmEntity
    }
}

