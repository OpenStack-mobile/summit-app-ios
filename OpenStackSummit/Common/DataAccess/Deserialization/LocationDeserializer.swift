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
    
    public func deserialize(json: JSON) -> BaseEntity {
        let location = Location()
        
        location.id = json["id"].intValue
        location.locationDescription = json["description"].stringValue
        
        return location
    }
}
