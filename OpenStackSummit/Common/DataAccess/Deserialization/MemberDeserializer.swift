//
//  MemberDeserializer.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/18/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON

public class MemberDeserializer: NSObject, IDeserializer {
    var deserializerFactory: DeserializerFactory!
    
    public func deserialize(json: JSON) -> BaseEntity {
        let member = Member()
        member.id = json["member_id"].intValue
        member.firstName = json["first_name"].stringValue
        member.lastName = json["last_name"].stringValue
        member.email = json["email"].stringValue
        member.irc = json["irc"].string ?? ""
        member.twitter = json["twitter"].string ?? ""
        member.bio = json["bio"].stringValue
                
        if let _ = json["schedule"].array {
            let deserializer = deserializerFactory.create(DeserializerFactories.SummitAttendee)
            member.attendeeRole = deserializer.deserialize(json) as! SummitAttendee
        }
        
        let speakerId = json["speaker_id"]
        if (speakerId.int != nil) {
            let deserializer = deserializerFactory.create(DeserializerFactories.PresentationSpeaker)
            member.speakerRole = deserializer.deserialize(json) as! PresentationSpeaker
            
        }
        
        return member
    }
}
