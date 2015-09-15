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
        member.firstName = json["first_name"].stringValue
        member.lastName = json["last_name"].stringValue
        member.email = json["email"].stringValue
        
        let deserializer = deserializerFactory.create(DeserializerFactories.SummitEvent)
        var event : SummitEvent
        
        for (_, eventJSON) in json["bookmarked_events"] {
            event = deserializer.deserialize(eventJSON) as! SummitEvent
            member.bookmarkedEvents.append(event)
        }
        
        for (_, eventJSON) in json["scheduled_events"] {
            event = deserializer.deserialize(eventJSON) as! SummitEvent
            member.scheduledEvents.append(event)
        }
        
        return member
    }
}
