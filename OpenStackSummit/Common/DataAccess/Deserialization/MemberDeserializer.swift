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
    
    public func deserialize(json: JSON) throws -> BaseEntity {
        try validateRequiredFields(["id"], inJson: json)

        let member = Member()
        member.id = json["member_id"].intValue
        member.firstName = json["first_name"].string ?? ""
        member.lastName = json["last_name"].string ?? ""
        member.email = json["email"].string ?? ""
        member.irc = json["irc"].string ?? ""
        member.twitter = json["twitter"].string ?? ""
        member.bio = json["bio"].string ?? ""
                
        if let _ = json["schedule"].array {
            let deserializer = deserializerFactory.create(DeserializerFactoryType.SummitAttendee)
            member.attendeeRole = try deserializer.deserialize(json) as? SummitAttendee
        }
        
        if (json["speaker"] != nil) {
            let deserializer = deserializerFactory.create(DeserializerFactoryType.PresentationSpeaker)
            member.speakerRole = try deserializer.deserialize(json["speaker"]) as? PresentationSpeaker
            
        }
        
        assert(!member.firstName.isEmpty)
        assert(!member.lastName.isEmpty)
        
        return member
    }
}
