//
//  SummitEventJSON.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import JSON

internal extension Event {
    
    enum JSONKey: String {
        
        case id, summit_id, title, description, social_description, start_date, end_date, allow_feedback, avg_feedback_rate, type_id, type, sponsors, speakers, location_id, location, tags, track_id, track, videos, rsvp_link, groups, rsvp_external, to_record, attachment, slides
    }
}

public extension Event {
    
    public init?(json: JSON.Value, summit: Identifier) {
        
        guard let JSONObject = json.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.integerValue,
            let title = JSONObject[JSONKey.title.rawValue]?.rawValue as? String,
            let startDate = JSONObject[JSONKey.start_date.rawValue]?.integerValue,
            let endDate = JSONObject[JSONKey.end_date.rawValue]?.integerValue,
            let eventType = JSONObject[JSONKey.type_id.rawValue]?.integerValue,
            let tagsJSONArray = JSONObject[JSONKey.tags.rawValue]?.arrayValue,
            let tags = Tag.from(json: tagsJSONArray),
            let allowFeedback = JSONObject[JSONKey.allow_feedback.rawValue]?.rawValue as? Bool,
            let sponsorsJSONArray = JSONObject[JSONKey.sponsors.rawValue]?.arrayValue,
            let sponsors = Identifier.from(json: sponsorsJSONArray),
            let averageFeedbackJSON = JSONObject[JSONKey.avg_feedback_rate.rawValue],
            let presentation = Presentation(json: json)
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
        self.externalRSVP = JSONObject[JSONKey.rsvp_external.rawValue]?.rawValue as? Bool ?? false
        self.willRecord = JSONObject[JSONKey.to_record.rawValue]?.rawValue as? Bool ?? false
        
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
        
        if let attachment = JSONObject[JSONKey.attachment.rawValue]?.rawValue as? String {
            
            self.attachment = attachment
            
        } else if let slidesJSONArray = JSONObject[JSONKey.slides.rawValue]?.arrayValue,
            let slides = String.from(json: slidesJSONArray) {
            
            self.attachment = slides.first
            
        } else {
            
            self.attachment = nil
        }
        
        // should never come in this JSON response
        self.groups = []
    }
}

extension MemberResponse.Event: JSONDecodable {
    
    fileprivate typealias JSONKey = Event.JSONKey
    
    public init?(json JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.integerValue,
            let summit = JSONObject[JSONKey.summit_id.rawValue]?.integerValue,
            let title = JSONObject[JSONKey.title.rawValue]?.rawValue as? String,
            let startDate = JSONObject[JSONKey.start_date.rawValue]?.integerValue,
            let endDate = JSONObject[JSONKey.end_date.rawValue]?.integerValue,
            let eventTypeJSON = JSONObject[JSONKey.type.rawValue],
            let eventType = EventType(json: eventTypeJSON),
            let tagsJSONArray = JSONObject[JSONKey.tags.rawValue]?.arrayValue,
            let tags = Tag.from(json: tagsJSONArray),
            let allowFeedback = JSONObject[JSONKey.allow_feedback.rawValue]?.rawValue as? Bool,
            let sponsorsJSONArray = JSONObject[JSONKey.sponsors.rawValue]?.arrayValue,
            let sponsors = Company.from(json: sponsorsJSONArray),
            let averageFeedbackJSON = JSONObject[JSONKey.avg_feedback_rate.rawValue],
            let presentation = MemberResponse.Presentation(json: JSONValue),
            let groupsJSONArray = JSONObject[JSONKey.groups.rawValue]?.arrayValue,
            let groups = Group.from(json: groupsJSONArray)
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
        self.externalRSVP = JSONObject[JSONKey.rsvp_external.rawValue]?.rawValue as? Bool ?? false
        self.willRecord = JSONObject[JSONKey.to_record.rawValue]?.rawValue as? Bool ?? false
        
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
            
            guard let track = MemberResponse.Track(json: trackJSON)
                else { return nil }
            
            self.track = track
            
        } else {
            
            self.track = nil
        }
        
        if let locationJSON = JSONObject[JSONKey.location.rawValue] {
            
            guard let location = Location(json: locationJSON)
                else { return nil }
            
            self.location = location
            
        } else {
            
            self.location = nil
        }
        
        if let videosJSONArray = JSONObject[JSONKey.videos.rawValue]?.arrayValue {
            
            guard let videos = Video.from(json: videosJSONArray)
                else { return nil }
            
            self.videos = videos
            
        } else {
            
            self.videos = []
        }
        
        if let attachment = JSONObject[JSONKey.attachment.rawValue]?.rawValue as? String {
            
            self.attachment = attachment
            
        } else if let slidesJSONArray = JSONObject[JSONKey.slides.rawValue]?.arrayValue,
            let slides = String.from(json: slidesJSONArray) {
            
            self.attachment = slides.first
            
        } else {
            
            self.attachment = nil
        }
    }
}

// MARK: - Extensions

public extension Event {
    
    /// Decodes from an array of JSON values.
    static func from(json array: JSON.Array, summit: Identifier) -> [Event]? {
        
        var jsonDecodables: ContiguousArray<Event> = ContiguousArray()
        
        jsonDecodables.reserveCapacity(array.count)
        
        for jsonValue in array {
            
            guard let jsonDecodable = self.init(json: jsonValue, summit: summit) else { return nil }
            
            jsonDecodables.append(jsonDecodable)
        }
        
        return Array(jsonDecodables)
    }
}
