//
//  PresentationSpeakerDeserializer.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/17/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON

public class PresentationSpeakerDeserializer: NSObject, IDeserializer {
    
    public func deserialize(json: JSON) -> BaseEntity {
        let presentationSpeaker = PresentationSpeaker()
        presentationSpeaker.id = json["id"].intValue
        presentationSpeaker.firstName = json["first_name"].stringValue
        presentationSpeaker.lastName = json["last_name"].stringValue
        presentationSpeaker.email = json["email"].stringValue
        presentationSpeaker.title = json["title"].stringValue
        presentationSpeaker.bio = json["bio"].stringValue
        presentationSpeaker.irc = json["irc"].stringValue
        presentationSpeaker.twitter = json["twitter"].stringValue
        presentationSpeaker.memberId = json["member_id"].intValue
        return presentationSpeaker
    }
}
