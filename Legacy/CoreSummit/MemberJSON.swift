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
        
        case first_name, last_name, email, title, bio, irc, twitter, member_id, pic, speaker, schedule
    }
}

extension Member: JSONDecodable {
    
    public init?(JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let memberID = JSONObject[JSONKey.member_id.rawValue]?.rawValue as? Int,
            let firstName = JSONObject[JSONKey.first_name.rawValue]?.rawValue as? String,
            let lastName = JSONObject[JSONKey.last_name.rawValue]?.rawValue as? String,
            let email = JSONObject[JSONKey.email.rawValue]?.rawValue as? String,
            let title = JSONObject[JSONKey.title.rawValue]?.rawValue as? String,
            let pictureURL = JSONObject[JSONKey.pic.rawValue]?.rawValue as? String,
            let biography = JSONObject[JSONKey.bio.rawValue]?.rawValue as? String,
            let irc = JSONObject[JSONKey.irc.rawValue]?.rawValue as? String,
            let twitter = JSONObject[JSONKey.twitter.rawValue]?.rawValue as? String
            else { return nil }
        
        self.identifier = memberID
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.title = title
        self.pictureURL = pictureURL
        self.biography = biography
        self.irc = irc
        self.twitter = twitter
        
        if let speakerJSON = JSONObject[JSONKey.speaker.rawValue] {
            
            guard let speaker = PresentationSpeaker(JSONValue: speakerJSON)
                else { return nil }
            
            self.speakerRole = speaker
            
        } else {
            
            self.speakerRole = nil
        }
        
        if JSONObject[JSONKey.schedule.rawValue] != nil {
            
            guard let attendee = SummitAttendee(JSONValue: JSONValue)
                else { return nil }
            
            self.attendeeRole = attendee
            
        } else {
            
            self.attendeeRole = nil
        }
    }
}