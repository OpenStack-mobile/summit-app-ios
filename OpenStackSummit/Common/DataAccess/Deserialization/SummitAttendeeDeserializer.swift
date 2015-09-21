//
//  SummitAttendeeDeserializer.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/18/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON

public class SummitAttendeeDeserializer: NSObject, IDeserializer {
    var deserializerStorage: DeserializerStorage!
    var deserializerFactory: DeserializerFactory!
    
    public func deserialize(json : JSON) throws -> BaseEntity {
        
        let summitAttendee: SummitAttendee
        
        if let summitAttendeeId = json.int {
            summitAttendee = deserializerStorage.get(summitAttendeeId)
        }
        else {
            summitAttendee = SummitAttendee()
            summitAttendee.id = json["id"].intValue

            let deserializer = deserializerFactory.create(DeserializerFactories.SummitEvent)
            var event : SummitEvent
            
            for (_, eventJSON) in json["schedule"] {
                event = try deserializer.deserialize(eventJSON) as! SummitEvent
                summitAttendee.scheduledEvents.append(event)
            }

            if(!deserializerStorage.exist(summitAttendee)) {
                deserializerStorage.add(summitAttendee)
            }
        }
        
        return summitAttendee
    }
}
