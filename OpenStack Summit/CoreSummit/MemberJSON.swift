//
//  MemberJSON.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/7/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

private extension Member {
    
    enum JSONKey: String {
        
        case id, first_name, last_name, gender, title, bio, irc, twitter, linked_in, member_id, pic, speaker, schedule, groups_events, groups, attendee, feedback
    }
}

extension Member: JSONDecodable {
    
    public init?(JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let memberID = JSONObject[JSONKey.member_id.rawValue]?.rawValue as? Int
                ?? JSONObject[JSONKey.id.rawValue]?.rawValue as? Int,
            let firstName = JSONObject[JSONKey.first_name.rawValue]?.rawValue as? String,
            let lastName = JSONObject[JSONKey.last_name.rawValue]?.rawValue as? String,
            let pictureURL = JSONObject[JSONKey.pic.rawValue]?.rawValue as? String,
            let groupsJSONArray = JSONObject[JSONKey.groups.rawValue]?.arrayValue,
            let groups = Group.fromJSON(groupsJSONArray)
            else { return nil }
        
        self.identifier = memberID
        self.firstName = firstName
        self.lastName = lastName
        self.pictureURL = pictureURL
        self.groups = Set(groups)
        
        // optional
        self.biography = JSONObject[JSONKey.bio.rawValue]?.rawValue as? String
        self.irc = JSONObject[JSONKey.irc.rawValue]?.rawValue as? String
        self.twitter = JSONObject[JSONKey.twitter.rawValue]?.rawValue as? String
        self.linkedIn = JSONObject[JSONKey.linked_in.rawValue]?.rawValue as? String
        self.gender = JSONObject[JSONKey.gender.rawValue]?.rawValue as? String
        
        if let speakerJSON = JSONObject[JSONKey.speaker.rawValue] {
            
            guard let speaker = Speaker(JSONValue: speakerJSON)
                else { return nil }
            
            self.speakerRole = speaker
            
        } else {
            
            self.speakerRole = nil
        }
        
        // not in this JSON response
        self.feedback = []
        self.groupEvents = []
        self.attendeeRole = nil
    }
}

extension MemberResponse.Member: JSONDecodable {
    
    private typealias JSONKey = Member.JSONKey
    
    public init?(JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.rawValue as? Int,
            let firstName = JSONObject[JSONKey.first_name.rawValue]?.rawValue as? String,
            let lastName = JSONObject[JSONKey.last_name.rawValue]?.rawValue as? String,
            let pictureURL = JSONObject[JSONKey.pic.rawValue]?.rawValue as? String,
            let groupsJSONArray = JSONObject[JSONKey.groups.rawValue]?.arrayValue,
            let groups = Group.fromJSON(groupsJSONArray),
            let groupEventsJSONArray = JSONObject[JSONKey.groups_events.rawValue]?.arrayValue,
            let groupEvents = MemberResponse.Event.fromJSON(groupEventsJSONArray),
            let feedbackJSONArray = JSONObject[JSONKey.feedback.rawValue]?.arrayValue,
            let feedback = MemberFeedback.fromJSON(feedbackJSONArray)
            else { return nil }
        
        self.identifier = identifier
        self.firstName = firstName
        self.lastName = lastName
        self.pictureURL = pictureURL
        self.groups = groups
        self.groupEvents = groupEvents
        self.feedback = feedback
        
        // optional
        self.biography = JSONObject[JSONKey.bio.rawValue]?.rawValue as? String
        self.irc = JSONObject[JSONKey.irc.rawValue]?.rawValue as? String
        self.twitter = JSONObject[JSONKey.twitter.rawValue]?.rawValue as? String
        self.linkedIn = JSONObject[JSONKey.linked_in.rawValue]?.rawValue as? String
        self.gender = JSONObject[JSONKey.gender.rawValue]?.rawValue as? String
        
        if let speakerJSON = JSONObject[JSONKey.speaker.rawValue] {
            
            guard let speaker = Speaker(JSONValue: speakerJSON)
                else { return nil }
            
            self.speakerRole = speaker
            
        } else {
            
            self.speakerRole = nil
        }
        
        if let attendeeJSON = JSONObject[JSONKey.attendee.rawValue] {
            
            guard let attendee = Attendee(JSONValue: attendeeJSON)
                else { return nil }
            
            self.attendeeRole = attendee
            
        } else {
            
            self.attendeeRole = nil
        }
    }
}
