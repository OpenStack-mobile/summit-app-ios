//
//  MemberJSON.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/7/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import JSON
import struct Foundation.URL

private extension Member {
    
    enum JSONKey: String {
        
        case id, first_name, last_name, gender, title, bio, irc, twitter, linked_in, member_id, pic, speaker, schedule, groups_events, groups, attendee, feedback, favorite_summit_events, affiliations
    }
}

extension Member: JSONDecodable {
    
    public init?(json JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let memberID = JSONObject[JSONKey.member_id.rawValue]?.integerValue
                ?? JSONObject[JSONKey.id.rawValue]?.integerValue,
            let firstName = JSONObject[JSONKey.first_name.rawValue]?.rawValue as? String,
            let lastName = JSONObject[JSONKey.last_name.rawValue]?.rawValue as? String,
            let picture = JSONObject[JSONKey.pic.rawValue]?.urlValue
            else { return nil }
        
        self.identifier = memberID
        self.firstName = firstName
        self.lastName = lastName
        self.picture = picture
        
        // optional
        self.biography = JSONObject[JSONKey.bio.rawValue]?.rawValue as? String
        self.irc = JSONObject[JSONKey.irc.rawValue]?.rawValue as? String
        self.twitter = JSONObject[JSONKey.twitter.rawValue]?.rawValue as? String
        self.linkedIn = JSONObject[JSONKey.linked_in.rawValue]?.rawValue as? String
        self.gender = JSONObject[JSONKey.gender.rawValue]?.rawValue as? String
        
        if let speakerJSON = JSONObject[JSONKey.speaker.rawValue] {
            
            guard let speaker = Speaker(json: speakerJSON)
                else { return nil }
            
            self.speakerRole = speaker
            
        } else {
            
            self.speakerRole = nil
        }
        
        if let groupsJSONArray = JSONObject[JSONKey.groups.rawValue]?.arrayValue {
            
            guard let groups = Group.from(json: groupsJSONArray)
                else { return nil }
            
            self.groups = Set(groups)
            
        } else {
            
            self.groups = []
        }
        
        if let affiliationsJSONArray = JSONObject[JSONKey.affiliations.rawValue]?.arrayValue {
            
            guard let affiliations = Affiliation.from(json: affiliationsJSONArray)
                else { return nil }
            
            self.affiliations = Set(affiliations)
            
        } else {
            
            self.affiliations = []
        }
        
        // not in this JSON response
        self.attendeeRole = nil
        self.feedback = []
        self.groupEvents = []
        self.favoriteEvents = []
    }
}

extension MemberResponse.Member: JSONDecodable {
    
    private typealias JSONKey = Member.JSONKey
    
    public init?(json JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.integerValue,
            let firstName = JSONObject[JSONKey.first_name.rawValue]?.rawValue as? String,
            let lastName = JSONObject[JSONKey.last_name.rawValue]?.rawValue as? String,
            let picture = JSONObject[JSONKey.pic.rawValue]?.urlValue,
            let groupsJSONArray = JSONObject[JSONKey.groups.rawValue]?.arrayValue,
            let groups = Group.from(json: groupsJSONArray),
            let groupEventsJSONArray = JSONObject[JSONKey.groups_events.rawValue]?.arrayValue,
            let groupEvents = MemberResponse.Event.from(json: groupEventsJSONArray),
            let feedbackJSONArray = JSONObject[JSONKey.feedback.rawValue]?.arrayValue,
            let feedback = MemberResponse.Feedback.from(json: feedbackJSONArray),
            let favoriteEventsJSONArray = JSONObject[JSONKey.favorite_summit_events.rawValue]?.arrayValue,
            let favoriteEvents = Identifier.from(json: favoriteEventsJSONArray)
            else { return nil }
        
        self.identifier = identifier
        self.firstName = firstName
        self.lastName = lastName
        self.picture = picture
        self.groups = groups
        self.groupEvents = groupEvents
        self.feedback = feedback
        self.favoriteEvents = favoriteEvents
        
        // optional
        self.biography = JSONObject[JSONKey.bio.rawValue]?.rawValue as? String
        self.irc = JSONObject[JSONKey.irc.rawValue]?.rawValue as? String
        self.twitter = JSONObject[JSONKey.twitter.rawValue]?.rawValue as? String
        self.linkedIn = JSONObject[JSONKey.linked_in.rawValue]?.rawValue as? String
        self.gender = JSONObject[JSONKey.gender.rawValue]?.rawValue as? String
        
        if let speakerJSON = JSONObject[JSONKey.speaker.rawValue] {
            
            guard let speaker = Speaker(json: speakerJSON)
                else { return nil }
            
            self.speakerRole = speaker
            
        } else {
            
            self.speakerRole = nil
        }
        
        if let attendeeJSON = JSONObject[JSONKey.attendee.rawValue] {
            
            guard let attendee = Attendee(json: attendeeJSON)
                else { return nil }
            
            self.attendeeRole = attendee
            
        } else {
            
            self.attendeeRole = nil
        }
        
        if let affiliationsJSONArray = JSONObject[JSONKey.affiliations.rawValue]?.arrayValue {
            
            guard let affiliations = Affiliation.from(json: affiliationsJSONArray)
                else { return nil }
            
            self.affiliations = affiliations
            
        } else {
            
            self.affiliations = []
        }
    }
}
