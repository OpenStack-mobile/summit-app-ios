//
//  Venue.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public struct Venue: LocationProtocol {
    
    public let identifier: Identifier
    
    public let type: ClassName
    
    public var name: String
    
    public var descriptionText: String?
    
    public var locationType: LocationType
    
    public var country: String
    
    public var address: String?
    
    public var city: String?
    
    public var zipCode: String?
    
    public var state: String?
    
    public var latitude: String?
    
    public var longitude: String?
    
    public var maps: [Image]
    
    public var images: [Image]
    
    public var floors: [VenueFloor]
}

// MARK: - Extensions

public extension Venue {
    
    var isInternal: Bool {
        
        return locationType == .Internal
    }
    
    var location: (latitude: Double, longitude: Double)? {
        
        guard let latitude = self.latitude,
            let longitude = self.longitude
            else { return nil }
        
        return ((latitude as NSString).doubleValue, (longitude as NSString).doubleValue)
    }
    
    var fullAddress: String {
        
        var fullAddress = address ?? ""
        
        var separator = fullAddress.isEmpty ? "" : ", "
        
        if let city = self.city {
            fullAddress += "\(separator)\(city)"
            separator = fullAddress.isEmpty ? "" : " "
        }
        
        if let state = self.state {
            fullAddress += "\(separator)\(state)"
            separator = fullAddress.isEmpty ? "" : " "
        }
        
        if let zipCode = self.zipCode {
            fullAddress += "\(separator)(\(zipCode))"
            separator = fullAddress.isEmpty ? "" : ", "
        }
        
        fullAddress += "\(separator)\(country)"
        
        return fullAddress
    }
}

// MARK: - Supporting Types

public extension Venue {
    
    public enum LocationType: String {
        
        case Internal, External, None
    }
    
    enum ClassName: String {
        
        case SummitVenue, SummitExternalLocation, SummitHotel, SummitAirport
    }
}
