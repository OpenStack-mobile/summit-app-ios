//
//  SummitAttendeeJSON.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/7/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

public extension SummitAttendee {
    
    enum JSONKey: String {
        
        case id, first_name, last_name, title, bio, irc, twitter, pic, speaker, schedule, feedback, tickets
    }
}

extension SummitAttendee: JSONDecodable {
    
    public init?(JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.rawValue as? Int,
            let firstName = JSONObject[JSONKey.first_name.rawValue]?.rawValue as? String,
            let lastName = JSONObject[JSONKey.last_name.rawValue]?.rawValue as? String,
            let pictureURL = JSONObject[JSONKey.pic.rawValue]?.rawValue as? String,
            let scheduledEventsJSONArray = JSONObject[JSONKey.schedule.rawValue]?.arrayValue,
            let scheduledEvents = Identifier.fromJSON(scheduledEventsJSONArray),
            let ticketsJSONArray = JSONObject[JSONKey.tickets.rawValue]?.arrayValue,
            let tickets = TicketType.fromJSON(ticketsJSONArray),
            let feedbackJSONArray = JSONObject[JSONKey.feedback.rawValue]?.arrayValue,
            let feedback = AttendeeFeedback.fromJSON(feedbackJSONArray)
            else { return nil }
        
        self.identifier = identifier
        self.firstName = firstName
        self.lastName = lastName
        self.pictureURL = pictureURL
        self.scheduledEvents = scheduledEvents
        self.tickets = tickets
        self.feedback = feedback
        
        // optional
        self.biography = JSONObject[JSONKey.bio.rawValue]?.rawValue as? String
        self.irc = JSONObject[JSONKey.irc.rawValue]?.rawValue as? String
        self.twitter = JSONObject[JSONKey.twitter.rawValue]?.rawValue as? String
    }
}