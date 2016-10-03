//
//  FeedbackOwnerJSON.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 10/3/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

public extension FeedbackOwner {
    
    enum JSONKey: String {
        
        case id, attendee_id, first_name, last_name
    }
}

extension FeedbackOwner: JSONDecodable {
    
    public init?(JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.rawValue as? Int,
            let attendee = JSONObject[JSONKey.attendee_id.rawValue]?.rawValue as? Int,
            let firstName = JSONObject[JSONKey.first_name.rawValue]?.rawValue as? String,
            let lastName = JSONObject[JSONKey.last_name.rawValue]?.rawValue as? String
            else { return nil }
        
        self.identifier = identifier
        self.attendee = attendee
        self.firstName = firstName
        self.lastName = lastName
    }
}
