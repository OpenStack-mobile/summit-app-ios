//
//  LocationDeserializer.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/16/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON

public class LocationDeserializer: NSObject, IDeserializer {
    
    public func deserialize(json: JSON) throws -> RealmEntity {
        try validateRequiredFields(["id"], inJson: json)
        
        let location = Location()
        
        location.id = json["id"].intValue
        location.locationDescription = json["description"].string ?? ""
        location.name = json["name"].string ?? ""
        
        assert(!location.name.isEmpty)
        
        return location
    }
}
