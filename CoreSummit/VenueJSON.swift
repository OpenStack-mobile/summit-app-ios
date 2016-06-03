//
//  VenueJSON.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

public extension Venue {
    
    enum JSONClassName: String {
        
        case SummitVenue, SummitExternalLocation
    }
    
    enum JSONKey: String {
        
        case lat, lng, address_1, city, state, zip_code, country, maps, images /* location_type */
    }
}

extension Venue: JSONDecodable {
    
    public init?(JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let classNameString = JSONObject[LocationJSONKey.class_name.rawValue]?.rawValue as? String,
            let className = JSONClassName(rawValue: classNameString),
            let identifier = JSONObject[LocationJSONKey.id.rawValue]?.rawValue as? Int,
            let name = JSONObject[LocationJSONKey.name.rawValue]?.rawValue as? String,
            let description = JSONObject[LocationJSONKey.description.rawValue]?.rawValue as? String,
            let latitude = JSONObject[JSONKey.lat.rawValue]?.rawValue as? String,
            let longitude = JSONObject[JSONKey.lng.rawValue]?.rawValue as? String,
            let address = JSONObject[JSONKey.address_1.rawValue]?.rawValue as? String,
            let city = JSONObject[JSONKey.city.rawValue]?.rawValue as? String,
            let state = JSONObject[JSONKey.state.rawValue]?.rawValue as? String,
            let zipCode = JSONObject[JSONKey.zip_code.rawValue]?.rawValue as? String,
            let country = JSONObject[JSONKey.country.rawValue]?.rawValue as? String,
            let mapsJSONArray = JSONObject[JSONKey.maps.rawValue]?.arrayValue,
            let maps = Image.fromJSON(mapsJSONArray),
            let imagesJSONArray = JSONObject[JSONKey.images.rawValue]?.arrayValue,
            let images = Image.fromJSON(imagesJSONArray)
            else { return nil }
        
        switch className {
            
        case .SummitVenue:
            
            self.isInternal = true
            
        case .SummitExternalLocation:
            
            self.isInternal = false
        }
        
        self.identifier = identifier
        self.name = name
        self.descriptionText = description // not in Realm
        self.latitude = latitude
        self.longitude = longitude
        self.address = address
        self.city = city
        self.state = state
        self.zipCode = zipCode
        self.country = country
        self.maps = maps
        self.images = images
    }
}