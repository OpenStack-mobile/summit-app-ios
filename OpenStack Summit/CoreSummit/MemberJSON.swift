//
//  MemberJSON.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/7/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

public extension Member {
    
    enum JSONKey: String {
        
        case id, first_name, last_name, title, bio, irc, twitter, linked_in, member_id, pic, speaker, schedule, groups_events
    }
}

extension Member: JSONDecodable {
    
    public init?(JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let memberID = JSONObject[JSONKey.member_id.rawValue]?.rawValue as? Int
                ?? JSONObject[JSONKey.id.rawValue]?.rawValue as? Int,
            let firstName = JSONObject[JSONKey.first_name.rawValue]?.rawValue as? String,
            let lastName = JSONObject[JSONKey.last_name.rawValue]?.rawValue as? String,
            let pictureURL = JSONObject[JSONKey.pic.rawValue]?.rawValue as? String
            else { return nil }
        
        self.identifier = memberID
        self.firstName = firstName
        self.lastName = lastName
        self.pictureURL = pictureURL
        
        // optional
        self.biography = JSONObject[JSONKey.bio.rawValue]?.rawValue as? String
        self.irc = JSONObject[JSONKey.irc.rawValue]?.rawValue as? String
        self.twitter = JSONObject[JSONKey.twitter.rawValue]?.rawValue as? String
        self.linkedIn = JSONObject[JSONKey.linked_in.rawValue]?.rawValue as? String
        
        if let speakerJSON = JSONObject[JSONKey.speaker.rawValue] {
            
            guard let speaker = Speaker(JSONValue: speakerJSON)
                else { return nil }
            
            self.speakerRole = speaker
            
        } else {
            
            self.speakerRole = nil
        }
        
        if JSONObject[JSONKey.schedule.rawValue] != nil {
            
            guard let attendee = Attendee(JSONValue: JSONValue)
                else { return nil }
            
            self.attendeeRole = attendee
            
        } else {
            
            self.attendeeRole = nil
        }
    }
}
