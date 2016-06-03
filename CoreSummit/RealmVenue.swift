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
    public let maps = List<RealmImage>()
    public let images = List<RealmImage>()
}

// MARK: - Encoding

extension Venue: RealmDecodable {
    
    public init(realmEntity: RealmVenue) {
        
        self.identifier = realmEntity.id
        self.name = realmEntity.name
        self.descriptionText = realmEntity.locationDescription
        self.address = realmEntity.address
        self.city = realmEntity.city
        self.zipCode = realmEntity.zipCode
        self.state = realmEntity.state
        self.country = realmEntity.country
        self.latitude = realmEntity.lat
        self.longitude = realmEntity.long
        self.locationType = realmEntity.isInternal ? .Internal : .External
        self.maps = Image.from(realm: realmEntity.maps)
        self.images = Image.from(realm: realmEntity.images)
    }
}
