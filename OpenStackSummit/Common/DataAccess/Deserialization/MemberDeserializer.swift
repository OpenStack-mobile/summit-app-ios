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
        member.id = json["id"].intValue
        member.firstName = json["firstName"].stringValue
        member.lastName = json["lastName"].stringValue
        member.email = json["email"].stringValue
        
        let deserializer = deserializerFactory.create(DeserializerFactories.SummitEvent)
        var event : SummitEvent
        
        for (_, eventJSON) in json["bookmarkedEvents"] {
            event = deserializer.deserialize(eventJSON) as! SummitEvent
            member.bookmarkedEvents.append(event)
        }
        
        for (_, eventJSON) in json["scheduledEvents"] {
            event = deserializer.deserialize(eventJSON) as! SummitEvent
            member.scheduledEvents.append(event)
        }
        
        return member
    }
}
