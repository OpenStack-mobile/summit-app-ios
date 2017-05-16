//
//  EventDataUpdateJSON.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 8/19/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import struct Foundation.Date
import JSON

private extension Event.DataUpdate {
    
    typealias JSONKey = Event.JSONKey
}

extension Event.DataUpdate: JSONDecodable {
    
    public init?(json JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.integerValue,
            let title = JSONObject[JSONKey.title.rawValue]?.rawValue as? String,
            let startDate = JSONObject[JSONKey.start_date.rawValue]?.integerValue,
            let endDate = JSONObject[JSONKey.end_date.rawValue]?.integerValue,
            let eventType = JSONObject[JSONKey.type_id.rawValue]?.integerValue,
            let tagsJSONArray = JSONObject[JSONKey.tags.rawValue]?.arrayValue,
            let tags = Tag.from(json: tagsJSONArray),
            let allowFeedback = JSONObject[JSONKey.allow_feedback.rawValue]?.rawValue as? Bool,
            let sponsorsJSONArray = JSONObject[JSONKey.sponsors.rawValue]?.arrayValue,
            let sponsors = Company.from(json: sponsorsJSONArray),
            let presentation = Presentation.DataUpdate(json: JSONValue),
            let averageFeedbackJSON = JSONObject[JSONKey.avg_feedback_rate.rawValue]
            else { return nil }
        
        self.identifier = identifier
        self.name = title
        self.start = Date(timeIntervalSince1970: TimeInterval(startDate))
        self.end = Date(timeIntervalSince1970: TimeInterval(endDate))
        self.type = eventType
        self.tags = Set(tags)
        self.allowFeedback = allowFeedback
        self.sponsors = Set(sponsors)
        self.presentation = presentation
        
        if let doubleValue = averageFeedbackJSON.rawValue as? Double {
            
            self.averageFeedback = doubleValue
            
        } else if let integerValue = averageFeedbackJSON.integerValue {
            
            self.averageFeedback = Double(integerValue)
            
        } else {
            
            return nil
        }
        
        // optional
        self.descriptionText = JSONObject[JSONKey.description.rawValue]?.rawValue as? String
        self.socialDescription = JSONObject[JSONKey.social_description.rawValue]?.rawValue as? String
        self.rsvp = JSONObject[JSONKey.rsvp_link.rawValue]?.rawValue as? String
        self.attachment = JSONObject[JSONKey.attachment.rawValue]?.rawValue as? String
        
        if let track = JSONObject[JSONKey.track_id.rawValue]?.integerValue,
            track > 0 {
            
            self.track = track
            
        } else {
            
            self.track = nil
        }
        
        if let location = JSONObject[JSONKey.location_id.rawValue]?.integerValue,
            location > 0 {
            
            self.location = location
            
        } else {
            
            self.location = nil
        }
        
        if let videosJSONArray = JSONObject[JSONKey.videos.rawValue]?.arrayValue {
            
            guard let videos = Video.from(json: videosJSONArray)
                else { return nil }
            
            self.videos = Set(videos)
            
        } else {
            
            self.videos = []
        }
        
        if let jsonArray = JSONObject[JSONKey.slides.rawValue]?.arrayValue {
            
            self.slides = Set(Slide.forceDecode(json: jsonArray))
            
        } else {
            
            self.slides = []
        }
        
        if let jsonArray = JSONObject[JSONKey.links.rawValue]?.arrayValue {
            
            self.links = Set(Link.forceDecode(json: jsonArray))
            
        } else {
            
            self.links = []
        }
    }
}
