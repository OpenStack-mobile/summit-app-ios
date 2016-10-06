//
//  FeedbackJSON.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

enum FeedbackJSONKey: String {
    
    case id, event_id, rate, note, created_date, member_id, owner_id, owner, attendee_id, first_name, last_name
}

extension Review: JSONDecodable {
    
    public init?(JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[FeedbackJSONKey.id.rawValue]?.rawValue as? Int,
            let rate = JSONObject[FeedbackJSONKey.rate.rawValue]?.rawValue as? Int,
            let review = JSONObject[FeedbackJSONKey.note.rawValue]?.rawValue as? String,
            let createdDate = JSONObject[FeedbackJSONKey.created_date.rawValue]?.rawValue as? Int,
            let event = JSONObject[FeedbackJSONKey.event_id.rawValue]?.rawValue as? Int,
            let ownerJSON = JSONObject[FeedbackJSONKey.owner.rawValue],
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

extension Review.Owner: JSONDecodable {
    
    public init?(JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let member = JSONObject[FeedbackJSONKey.id.rawValue]?.rawValue as? Int,
            let attendee = JSONObject[FeedbackJSONKey.attendee_id.rawValue]?.rawValue as? Int,
            let firstName = JSONObject[FeedbackJSONKey.first_name.rawValue]?.rawValue as? String,
            let lastName = JSONObject[FeedbackJSONKey.last_name.rawValue]?.rawValue as? String
            else { return nil }
        
        self.member = member
        self.attendee = attendee
        self.firstName = firstName
        self.lastName = lastName
    }
}

extension AttendeeFeedback: JSONDecodable {
    
    public init?(JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[FeedbackJSONKey.id.rawValue]?.rawValue as? Int,
            let rate = JSONObject[FeedbackJSONKey.rate.rawValue]?.rawValue as? Int,
            let review = JSONObject[FeedbackJSONKey.note.rawValue]?.rawValue as? String,
            let createdDate = JSONObject[FeedbackJSONKey.created_date.rawValue]?.rawValue as? Int,
            let event = JSONObject[FeedbackJSONKey.event_id.rawValue]?.rawValue as? Int,
            let member = JSONObject[FeedbackJSONKey.member_id.rawValue]?.rawValue as? Int,
            let attendee = JSONObject[FeedbackJSONKey.attendee_id.rawValue]?.rawValue as? Int
            else { return nil }
        
        self.identifier = identifier
        self.rate = rate
        self.review = review
        self.date = Date(timeIntervalSince1970: TimeInterval(createdDate))
        self.event = event
        self.member = member
        self.attendee = attendee
    }
}

