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
        
        case id, title, description, start_date, end_date, allow_feedback, avg_feedback_rate, type_id, summit_types, sponsors, speakers, location_id, tags, track_id
    }
}

extension SummitEvent: JSONDecodable {
    
    public init?(JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.rawValue as? Int,
            let title = JSONObject[JSONKey.title.rawValue]?.rawValue as? String,
            let description = JSONObject[JSONKey.description.rawValue]?.rawValue as? String,
            let startDate = JSONObject[JSONKey.start_date.rawValue]?.rawValue as? Int,
            let endDate = JSONObject[JSONKey.end_date.rawValue]?.rawValue as? Int,
            let eventTypeJSON = JSONObject[JSONKey.type_id.rawValue],
            let eventType = EventType(JSONValue: eventTypeJSON),
            let summitTypesJSONArray = JSONObject[JSONKey.summit_types.rawValue]?.arrayValue,
            let summitTypes = SummitType.fromJSON(summitTypesJSONArray),
            let tagsJSONArray = JSONObject[JSONKey.tags.rawValue]?.arrayValue,
            let tags = Tag.fromJSON(tagsJSONArray),
            let allowFeedback = JSONObject[JSONKey.allow_feedback.rawValue]?.rawValue as? Bool,
            let averageFeedback = JSONObject[JSONKey.avg_feedback_rate.rawValue]?.rawValue as? Double,
            let typeJSON = JSONObject[JSONKey.type_id.rawValue],
            let type = EventType(JSONValue: typeJSON),
            let sponsorsJSONArray = JSONObject[JSONKey.sponsors.rawValue]?.arrayValue,
            let sponsors = Company.fromJSON(sponsorsJSONArray),
            let speakersJSONArray = JSONObject[JSONKey.speakers.rawValue]?.arrayValue,
            let speakers = PresentationSpeaker.fromJSON(speakersJSONArray),
            let locationIdentifier = JSONObject[JSONKey.location_id.rawValue]?.rawValue as? Int
            /* let trackIdentifier = JSONObject[JSONKey.track_id.rawValue]?.rawValue as? Int */
            else { return nil }
        
        self.identifier = identifier
        self.name = title
        self.descriptionText = description
        self.start = Date(timeIntervalSince1970: TimeInterval(startDate))
        self.end = Date(timeIntervalSince1970: TimeInterval(endDate))
        self.type = eventType
        self.summitTypes = summitTypes
        self.tags = tags
        self.averageFeedback = averageFeedback
        self.allowFeedback = allowFeedback
        self.type = type
        self.sponsors = sponsors
        self.speakers = speakers
        //self.trackIdentifier = trackIdentifier
        
        // location
        self.location
    }
}
