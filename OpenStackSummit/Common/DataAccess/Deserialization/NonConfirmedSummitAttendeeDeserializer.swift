//
//  NonConfirmedSummitAttendeeDeserializer.swift
//  OpenStackSummit
//
//  Created by Claudio on 4/5/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON
import Crashlytics

public class NonConfirmedSummitAttendeeDeserializer: NSObject, IDeserializer {
    
    public func deserialize(json : JSON) throws -> RealmEntity {
        
        let nonConfirmedSummitAttendee = NonConfirmedSummitAttendee()
        
        nonConfirmedSummitAttendee.id = json["external_id"].int ?? 0
        nonConfirmedSummitAttendee.name = (json["first_name"].string ?? "") +  " " + (json["last_name"].string ?? "")
        
        return nonConfirmedSummitAttendee
    }    
}
