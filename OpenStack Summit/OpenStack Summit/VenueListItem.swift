//
//  VenueListItem.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/6/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import CoreSummit

public struct VenueListItem: RealmDecodable {
    
    public let identifier: Identifier
    
    public let name: String
    
    public let descriptionText: String
    
    public let address: String
    
    public let latitude: Double
    
    public let longitude: Double
    
    public let backgroundImageURL: String?
    
    public init(realmEntity venue: RealmVenue) {
        
        self.identifier = venue.id
        self.name = venue.name
        self.descriptionText = venue.locationDescription
        self.address = VenueListItem.getAddress(venue)
        self.latitude = Double(venue.lat) ?? 0.0
        self.longitude = Double(venue.long) ?? 0.0
        self.backgroundImageURL = venue.images.first?.url
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