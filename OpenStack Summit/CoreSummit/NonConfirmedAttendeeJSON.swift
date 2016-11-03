//
//  NonConfirmedSummitAttendeeJSON.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

public extension NonConfirmedAttendee {
    
    enum JSONKey: String {
        
        case external_id, first_name, last_name
    }
}

extension NonConfirmedAttendee: JSONDecodable {
    
    public init?(JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.external_id.rawValue]?.rawValue as? Int,
            let firstName = JSONObject[JSONKey.first_name.rawValue]?.rawValue as? String,
            let lastName = JSONObject[JSONKey.last_name.rawValue]?.rawValue as? String
            else { return nil }
        
        self.identifier = identifier
        self.firstName = firstName
        self.lastName = lastName
    }
}