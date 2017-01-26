//
//  SummitEventJSON.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

internal extension Event {
    
    enum JSONKey: String {
        
        case id, summit_id, title, description, social_description, start_date, end_date, allow_feedback, avg_feedback_rate, type_id, type, sponsors, speakers, location_id, location, tags, track_id, track, videos, rsvp_link, groups
    }
}

extension Event: JSONParametrizedDecodable {
    
    public init?(JSONValue: JSON.Value, parameters summit: Identifier) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.rawValue as? Int,
            let title = JSONObject[JSONKey.title.rawValue]?.rawValue as? String,
            let startDate = JSONObject[JSONKey.start_date.rawValue]?.rawValue as? Int,
            let endDate = JSONObject[JSONKey.end_date.rawValue]?.rawValue as? Int,
            let eventTypeJSON = JSONObject[JSONKey.type_id.rawValue],
            let eventType = Int(JSONValue: eventTypeJSON),
            let tagsJSONArray = JSONObject[JSONKey.tags.rawValue]?.arrayValue,
            let tags = Tag.fromJSON(tagsJSONArray),
            let allowFeedback = JSONObject[JSONKey.allow_feedback.rawValue]?.rawValue as? Bool,
            let sponsorsJSONArray = JSONObject[JSONKey.sponsors.rawValue]?.arrayValue,
            let sponsors = Identifier.fromJSON(sponsorsJSONArray),
            let averageFeedbackJSON = JSONObject[JSONKey.avg_feedback_rate.rawValue],
            let presentation = Presentation(JSONValue: JSONValue)
            else { return nil }
        
        self.identifier = identifier
        self.summit = summit
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
            
        } else if let integerValue = averageFeedbackJSON.rawValue as? Int {
            
            self.averageFeedback = Double(integerValue)
            
        } else {
            
            return nil
        }
        
        // optional
        self.descriptionText = JSONObject[JSONKey.description.rawValue]?.rawValue as? String
        self.socialDescription = JSONObject[JSONKey.social_description.rawValue]?.rawValue as? String
        self.rsvp = JSONObject[JSONKey.rsvp_link.rawValue]?.rawValue as? String
        
        if let track = JSONObject[JSONKey.track_id.rawValue]?.rawValue as? Int where track > 0 {
            
            self.track = track
            
        } else {
            
            self.track = nil
        }
        
        if let location = JSONObject[JSONKey.location_id.rawValue]?.rawValue as? Int
            where location > 0 {
            
            self.location = location
            
        } else {
            
            self.location = nil
        }
        
        if let videosJSONArray = JSONObject[JSONKey.videos.rawValue]?.arrayValue {
            
            guard let videos = Video.fromJSON(videosJSONArray)
                else { return nil }
            
            self.videos = Set(videos)
            
        } else {
            
            self.videos = []
        }
        
        // should never come in this JSON response
        self.groups = []
    }
}

extension MemberResponse.Event: JSONDecodable {
    
    private typealias JSONKey = Event.JSONKey
    
    public init?(JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.rawValue as? Int,
            let summit = JSONObject[JSONKey.summit_id.rawValue]?.rawValue as? Int,
            let title = JSONObject[JSONKey.title.rawValue]?.rawValue as? String,
            let startDate = JSONObject[JSONKey.start_date.rawValue]?.rawValue as? Int,
            let endDate = JSONObject[JSONKey.end_date.rawValue]?.rawValue as? Int,
            let eventTypeJSON = JSONObject[JSONKey.type.rawValue],
            let eventType = EventType(JSONValue: eventTypeJSON),
            let tagsJSONArray = JSONObject[JSONKey.tags.rawValue]?.arrayValue,
            let tags = Tag.fromJSON(tagsJSONArray),
            let allowFeedback = JSONObject[JSONKey.allow_feedback.rawValue]?.rawValue as? Bool,
            let sponsorsJSONArray = JSONObject[JSONKey.sponsors.rawValue]?.arrayValue,
            let sponsors = Company.fromJSON(sponsorsJSONArray),
            let averageFeedbackJSON = JSONObject[JSONKey.avg_feedback_rate.rawValue],
            let presentation = MemberResponse.Presentation(JSONValue: JSONValue),
            let groupsJSONArray = JSONObject[JSONKey.groups.rawValue]?.arrayValue,
            let groups = Group.fromJSON(groupsJSONArray)
            else { return nil }
        
        self.identifier = identifier
        self.summit = summit
        self.name = title
        self.start = Date(timeIntervalSince1970: TimeInterval(startDate))
        self.end = Date(timeIntervalSince1970: TimeInterval(endDate))
        self.type = eventType
        self.tags = tags
        self.allowFeedback = allowFeedback
        self.sponsors = sponsors
        self.presentation = presentation
        self.groups = groups
        
        if let doubleValue = averageFeedbackJSON.rawValue as? Double {
            
            self.averageFeedback = doubleValue
            
        } else if let integerValue = averageFeedbackJSON.rawValue as? Int {
            
            self.averageFeedback = Double(integerValue)
            
        } else {
            
            return nil
        }
        
        // optional
        self.descriptionText = JSONObject[JSONKey.description.rawValue]?.rawValue as? String
        self.socialDescription = JSONObject[JSONKey.social_description.rawValue]?.rawValue as? String
        self.rsvp = JSONObject[JSONKey.rsvp_link.rawValue]?.rawValue as? String
        
        if let trackJSON = JSONObject[JSONKey.track.rawValue] {
            
            guard let track = MemberResponse.Track(JSONValue: trackJSON)
                else { return nil }
            
            self.track = track
            
        } else {
            
            self.track = nil
        }
        
        if let locationJSON = JSONObject[JSONKey.location.rawValue] {
            
            guard let location = Location(JSONValue: locationJSON)
                else { return nil }
            
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
    }
}
