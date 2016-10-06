//
//  EventDataUpdateJSON.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 8/19/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

public extension Event.DataUpdate {
    
    typealias JSONKey = SummitEvent.JSONKey
}

extension Event.DataUpdate: JSONDecodable {
    
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
            /* let speakersJSONArray = JSONObject[JSONKey.speakers.rawValue]?.arrayValue, */
            /* let speakers = PresentationSpeaker.fromJSON(speakersJSONArray), */
            /* let trackIdentifier = JSONObject[JSONKey.track_id.rawValue]?.rawValue as? Int */
            let locationIdentifier = JSONObject[JSONKey.location_id.rawValue]?.rawValue as? Int,
            let presentation = Presentation.DataUpdate(JSONValue: JSONValue),
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
        self.location = locationIdentifier
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
        
        if let videosJSONArray = JSONObject[JSONKey.videos.rawValue]?.arrayValue {
            
            guard let videos = Video.fromJSON(videosJSONArray)
                else { return nil }
            
            self.videos = videos
            
        } else {
            
            self.videos = []
        }
        
    }
}
