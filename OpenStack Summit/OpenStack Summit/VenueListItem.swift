//
//  VenueListItem.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/6/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import CoreSummit
import Foundation
import CoreLocation

public struct VenueListItem: RealmDecodable {
    
    public let identifier: Identifier
    
    public let name: String
    
    public let descriptionText: String
    
    public let address: String
    
    public let location: CLLocationCoordinate2D?
    
    public let backgroundImageURL: String?
    
    public var maps: [String]
    
    public let images: [String]
    
    public init(realmEntity venue: RealmVenue) {
        
        assert(venue.name != "", "Empty venue: \(venue)")
        
        self.identifier = venue.id
        self.name = venue.name
        self.descriptionText = venue.locationDescription
        self.address = VenueListItem.getAddress(venue)
        self.backgroundImageURL = venue.images.first?.url
        self.maps = venue.maps.map { $0.url }
        
        let floors = venue.floors.sort { $0.number < $1.number }
        self.maps.appendContentsOf(floors.map { $0.imageURL }.filter { $0 != "" })
        
        self.images = venue.images.map { $0.url }
        
        // location
        if let latitude = Double(venue.lat),
            let longitude = Double(venue.long) {
            
            self.location = CLLocationCoordinate2DMake(latitude, longitude)
        } else {
            
            self.location = nil
        }
    }
}

// MARK: - Private

private extension VenueListItem {
    
    static func getAddress(venue: RealmVenue) -> String {
        var fullAddress = venue.address
        
        var separator = fullAddress.isEmpty ? "" : ", "
        if (!venue.city.isEmpty) {
            fullAddress += "\(separator)\(venue.city)"
            separator = fullAddress.isEmpty ? "" : " "
        }
        
        if (!venue.state.isEmpty) {
            fullAddress += "\(separator)\(venue.state)"
            separator = fullAddress.isEmpty ? "" : " "
        }
        
        if (!venue.zipCode.isEmpty) {
            fullAddress += "\(separator)(\(venue.zipCode))"
            separator = fullAddress.isEmpty ? "" : ", "
        }
        
        if (!venue.country.isEmpty) {
            fullAddress += "\(separator)\(venue.country)"
        }
        
        return fullAddress
    }
}