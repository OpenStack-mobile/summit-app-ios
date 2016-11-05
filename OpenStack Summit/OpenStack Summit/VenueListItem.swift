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

public struct VenueListItem: CoreDataDecodable {
    
    public let identifier: Identifier
    
    public let name: String
    
    public let descriptionText: String
    
    public let address: String
    
    public let location: CLLocationCoordinate2D?
    
    public let backgroundImageURL: String?
    
    public var maps: [String]
    
    public let images: [String]
    
    public init(managedObject venue: VenueManagedObject) {
        
        assert(venue.name != "", "Empty venue: \(venue)")
        
        self.identifier = venue.identifier
        self.name = venue.name
        self.descriptionText = venue.descriptionText ?? ""
        self.address = VenueListItem.getAddress(venue)
        self.backgroundImageURL = venue.images.first?.url
        self.maps = venue.maps.map { $0.url }
        
        let floors = venue.floors.sort { $0.number < $1.number }
        self.maps.appendContentsOf(floors.map { $0.imageURL ?? "" }.filter { $0.isEmpty == false })
        
        self.images = venue.images.map { $0.url }
        
        // location
        if let latitude = Double(venue.latitude ?? ""),
            let longitude = Double(venue.longitude ?? "") {
            
            self.location = CLLocationCoordinate2DMake(latitude, longitude)
        } else {
            
            self.location = nil
        }
    }
}

// MARK: - Private

private extension VenueListItem {
    
    static func getAddress(venue: VenueManagedObject) -> String {
        
        var fullAddress = venue.address ?? ""
        
        var separator = fullAddress.isEmpty ? "" : ", "
        if let city = venue.city {
            fullAddress += "\(separator)\(city)"
            separator = fullAddress.isEmpty ? "" : " "
        }
        
        if let state = venue.state {
            fullAddress += "\(separator)\(state)"
            separator = fullAddress.isEmpty ? "" : " "
        }
        
        if let zipCode = venue.zipCode {
            fullAddress += "\(separator)(\(zipCode))"
            separator = fullAddress.isEmpty ? "" : ", "
        }
        
        if venue.country.isEmpty == false {
            fullAddress += "\(separator)\(venue.country)"
        }
        
        return fullAddress
    }
}