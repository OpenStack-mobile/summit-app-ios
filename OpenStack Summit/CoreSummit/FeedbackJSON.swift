//
//  FeedbackJSON.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

public extension Feedback {
    
    enum JSONKey: String {
        
        case id, event_id, rate, note, created_date, member_id, owner_id, owner
    }
}

extension Feedback: JSONDecodable {
    
    public init?(JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.rawValue as? Int,
            let rate = JSONObject[JSONKey.rate.rawValue]?.rawValue as? Int,
            let review = JSONObject[JSONKey.note.rawValue]?.rawValue as? String,
            let createdDate = JSONObject[JSONKey.created_date.rawValue]?.rawValue as? Int,
            let event = JSONObject[JSONKey.event_id.rawValue]?.rawValue as? Int,
            let ownerJSON = JSONObject[JSONKey.owner.rawValue],
            let owner = Owner(JSONValue: ownerJSON)
            else { return nil }
        
        self.identifier = identifier
        self.rate = rate
        self.review = review
        self.date = Date(timeIntervalSince1970: TimeInterval(createdDate))
        self.event = event
        self.owner = owner
    }
}

