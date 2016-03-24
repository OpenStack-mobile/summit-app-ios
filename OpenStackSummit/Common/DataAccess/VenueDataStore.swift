//
//  VenueDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 3/23/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IVenueDataStore {
    func addImage(image: Image, toVenue venue:Venue) throws
    func removeImage(image: Image, fromVenue venue:Venue) throws
    func addMap(map: Image, toVenue venue:Venue) throws
    func removeMap(image: Image, fromVenue venue:Venue) throws
}

public class VenueDataStore: GenericDataStore, IVenueDataStore {
    public func addImage(image: Image, toVenue venue:Venue) throws {
        try self.realm.write {
            let index = venue.images.indexOf("id = %@", image.id)
            if (index == nil) {
                venue.images.append(image)
            }
        }
    }

    public func removeImage(image: Image, fromVenue venue:Venue) throws {
        try self.realm.write {
            if let index = venue.images.indexOf("id = %@", image.id) {
                venue.images.removeAtIndex(index)
            }
        }
        
    }
    
    public func addMap(map: Image, toVenue venue:Venue) throws {
        try self.realm.write {
            let index = venue.maps.indexOf("id = %@", map.id)
            if (index == nil) {
                venue.maps.append(map)
            }
        }
    }
    
    public func removeMap(map: Image, fromVenue venue:Venue) throws {
        try self.realm.write {
            if let index = venue.maps.indexOf("id = %@", map.id) {
                venue.maps.removeAtIndex(index)
            }
        }
    }
}