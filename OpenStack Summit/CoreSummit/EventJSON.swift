//
//  SummitEventJSON.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

public extension SummitEvent {
    
    enum JSONKey: String {
        
        case id, title, description, start_date, end_date, allow_feedback, avg_feedback_rate, type_id, summit_types, sponsors, speakers, location_id, tags, track_id, videos, rsvp_link
    }
}

extension SummitEvent: JSONDecodable {
    
    public init?(JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.rawValue as? Int,
            let title = JSONObject[JSONKey.title.rawValue]?.rawValue as? String,
            let startDate = JSONObject[JSONKey.start_date.rawValue]?.rawValue as? Int,
            let endDate = JSONObject[JSONKey.end_date.rawValue]?.rawValue as? Int,
            let eventTypeJSON = JSONObject[JSONKey.type_id.rawValue],
            let eventType = Int(JSONValue: eventTypeJSON),
            let summitTypesJSONArray = JSONObject[JSONKey.summit_types.rawValue]?.arrayValue,
            let summitTypes = Int.fromJSON(summitTypesJSONArray),
            let tagsJSONArray = JSONObject[JSONKey.tags.rawValue]?.arrayValue,
            let tags = Tag.fromJSON(tagsJSONArray),
            let allowFeedback = JSONObject[JSONKey.allow_feedback.rawValue]?.rawValue as? Bool,
            let typeJSON = JSONObject[JSONKey.type_id.rawValue],
            let type = Identifier(JSONValue: typeJSON),
            let sponsorsJSONArray = JSONObject[JSONKey.sponsors.rawValue]?.arrayValue,
            let sponsors = Identifier.fromJSON(sponsorsJSONArray),
            let averageFeedbackJSON = JSONObject[JSONKey.avg_feedback_rate.rawValue]
            else { return nil }
        
        self.identifier = identifier
        self.name = title
        self.start = Date(timeIntervalSince1970: TimeInterval(startDate))
        self.end = Date(timeIntervalSince1970: TimeInterval(endDate))
        self.type = eventType
        self.summitTypes = summitTypes
        self.tags = tags
        self.allowFeedback = allowFeedback
        self.type = type
        self.sponsors = sponsors
        
        if let doubleValue = averageFeedbackJSON.rawValue as? Double {
            
            self.averageFeedback = doubleValue
            
        } else if let integerValue = averageFeedbackJSON.rawValue as? Int {
            
            self.averageFeedback = Double(integerValue)
            
        } else {
            
            return nil
        }
        
        // optional
        self.descriptionText = JSONObject[JSONKey.description.rawValue]?.rawValue as? String
        self.rsvp = JSONObject[JSONKey.rsvp_link.rawValue]?.rawValue as? String
        
        if let location = JSONObject[JSONKey.location_id.rawValue]?.rawValue as? Int
            where location > 0 {
            
            self.location = location
            
        } else {
            
            self.location = nil
        }
        
        if let videosJSONArray = JSONObject[JSONKey.videos.rawValue]?.arrayValue {
            
            guard let videos = Video.fromJSON(videosJSONArray)
                else { return nil }
            
            self.videos = videos
            
        } else {
            
            self.videos = []
        }
        
        // decode presentation
        if JSONObject[JSONKey.track_id.rawValue] != nil {
            
            guard let presentation = Presentation(JSONValue: JSONValue)
                else { return nil }
            
            self.presentation = presentation
            
        } else {
            
            self.presentation = nil
        }
    }
}
