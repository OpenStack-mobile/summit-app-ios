//
//  VenueDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 3/23/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import CoreSummit

public protocol VenueDataStoreProtocol {
    
    func addImage(image: RealmImage, toVenue venue: RealmVenue) throws
    func removeImage(image: RealmImage, fromVenue venue: RealmVenue) throws
    func addMap(map: RealmImage, toVenue venue: RealmVenue) throws
    func removeMap(image: RealmImage, fromVenue venue: RealmVenue) throws
}

public class VenueDataStore: GenericDataStore, VenueDataStoreProtocol {
    
    public func addImage(image: RealmImage, toVenue venue: RealmVenue) throws {
        try self.realm.write {
            let index = venue.images.indexOf("id = %@", image.id)
            if (index == nil) {
                venue.images.append(image)
            }
        }
    }

    public func removeImage(image: RealmImage, fromVenue venue: RealmVenue) throws {
        try self.realm.write {
            if let index = venue.images.indexOf("id = %@", image.id) {
                venue.images.removeAtIndex(index)
            }
        }
        
    }
    
    public func addMap(map: RealmImage, toVenue venue: RealmVenue) throws {
        try self.realm.write {
            let index = venue.maps.indexOf("id = %@", map.id)
            if (index == nil) {
                venue.maps.append(map)
            }
        }
    }
    
    public func removeMap(map: RealmImage, fromVenue venue: RealmVenue) throws {
        try self.realm.write {
            if let index = venue.maps.indexOf("id = %@", map.id) {
                venue.maps.removeAtIndex(index)
            }
        }
    }
}