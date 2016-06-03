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
        
        case SummitVenue, SummitExternalLocation, SummitHotel, SummitAirport
    }
    
    enum JSONKey: String {
        
        case lat, lng, address_1, city, state, zip_code, country, maps, images, location_type
    }
}

extension Venue: JSONDecodable {
    
    public init?(JSONValue: JSON.Value) {
                
        guard let JSONObject = JSONValue.objectValue,
            let classNameString = JSONObject[LocationJSONKey.class_name.rawValue]?.rawValue as? String,
            let _ = JSONClassName(rawValue: classNameString), // not stored, but verified
            let identifier = JSONObject[LocationJSONKey.id.rawValue]?.rawValue as? Int,
            let name = JSONObject[LocationJSONKey.name.rawValue]?.rawValue as? String,
            let country = JSONObject[JSONKey.country.rawValue]?.rawValue as? String,
            let mapsJSONArray = JSONObject[JSONKey.maps.rawValue]?.arrayValue,
            let maps = Image.fromJSON(mapsJSONArray),
            let imagesJSONArray = JSONObject[JSONKey.images.rawValue]?.arrayValue,
            let images = Image.fromJSON(imagesJSONArray),
            let locationTypeString = JSONObject[JSONKey.location_type.rawValue]?.rawValue as? String,
            let locationType = LocationType(rawValue: locationTypeString)
            else { return nil }
        
        self.identifier = identifier
        self.name = name
        self.country = country
        self.maps = maps
        self.images = images
        self.locationType = locationType
        
        // optional
        self.latitude = JSONObject[JSONKey.lat.rawValue]?.rawValue as? String
        self.longitude = JSONObject[JSONKey.lng.rawValue]?.rawValue as? String
        self.address = JSONObject[JSONKey.address_1.rawValue]?.rawValue as? String
        self.city = JSONObject[JSONKey.city.rawValue]?.rawValue as? String
        self.state = JSONObject[JSONKey.state.rawValue]?.rawValue as? String
        self.zipCode = JSONObject[JSONKey.zip_code.rawValue]?.rawValue as? String
        
        
        // not in Realm
        self.descriptionText = JSONObject[LocationJSONKey.description.rawValue]?.rawValue as? String
    }
}