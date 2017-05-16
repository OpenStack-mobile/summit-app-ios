//
//  FeedbackJSON.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import JSON

extension Feedback: JSONDecodable {
    
    private enum JSONKey: String {
        
        case id, event_id, rate, note, created_date, owner
    }
    
    public init?(json JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.integerValue,
            let rate = JSONObject[JSONKey.rate.rawValue]?.integerValue,
            let review = JSONObject[JSONKey.note.rawValue]?.rawValue as? String,
            let createdDate = JSONObject[JSONKey.created_date.rawValue]?.integerValue,
            let event = JSONObject[JSONKey.event_id.rawValue]?.integerValue,
            let memberJSON = JSONObject[JSONKey.owner.rawValue],
            let member = Member(json: memberJSON)
            else { return nil }
        
        self.identifier = identifier
        self.rate = Int(rate)
        self.review = review
        self.date = Date(timeIntervalSince1970: TimeInterval(createdDate))
        self.event = event
        self.member = member
    }
}

extension MemberResponse.Feedback: JSONDecodable {
    
    private enum JSONKey: String {
        
        case id, event_id, rate, note, created_date, owner_id
    }
    
    public init?(json JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.integerValue,
            let rate = JSONObject[JSONKey.rate.rawValue]?.integerValue,
            let review = JSONObject[JSONKey.note.rawValue]?.rawValue as? String,
            let createdDate = JSONObject[JSONKey.created_date.rawValue]?.integerValue,
            let event = JSONObject[JSONKey.event_id.rawValue]?.integerValue,
            let member = JSONObject[JSONKey.owner_id.rawValue]?.integerValue
            else { return nil }
        
        self.identifier = identifier
        self.rate = Int(rate)
        self.review = review
        self.date = Date(timeIntervalSince1970: TimeInterval(createdDate))
        self.event = event
        self.member = member
    }
}

