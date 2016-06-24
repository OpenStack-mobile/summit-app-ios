//
//  PresentationSpeakerJSON.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

public extension PresentationSpeaker {
    
    enum JSONKey: String {
        
        case id, first_name, last_name, email, title, bio, irc, twitter, member_id, pic
    }
}

extension PresentationSpeaker: JSONDecodable {
    
    public init?(JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.rawValue as? Int,
            let firstName = JSONObject[JSONKey.first_name.rawValue]?.rawValue as? String,
            let lastName = JSONObject[JSONKey.last_name.rawValue]?.rawValue as? String,
            let email = JSONObject[JSONKey.email.rawValue]?.rawValue as? String,
            let title = JSONObject[JSONKey.title.rawValue]?.rawValue as? String,
            let pictureURL = JSONObject[JSONKey.pic.rawValue]?.rawValue as? String,
            let biography = JSONObject[JSONKey.bio.rawValue]?.rawValue as? String,
            let memberID = JSONObject[JSONKey.member_id.rawValue]?.rawValue as? Int
            else { return nil }
        
        self.identifier = identifier
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.title = title
        self.pictureURL = pictureURL
        self.biography = biography
        self.memberIdentifier = memberID
        
        // optional
        self.irc = JSONObject[JSONKey.irc.rawValue]?.rawValue as? String
        self.twitter = JSONObject[JSONKey.twitter.rawValue]?.rawValue as? String
    }
}