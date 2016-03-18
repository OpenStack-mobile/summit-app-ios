//
//  EventTypeDeserializer.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/15/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON

public class EventTypeDeserializer: NamedEntityDeserializer, IDeserializer {
    var deserializerStorage: DeserializerStorage!
    
    public func deserialize(json : JSON) throws -> BaseEntity {
        let eventType : EventType
        
        if let eventTypeId = json.int {
            guard let check: EventType = deserializerStorage.get(eventTypeId) else {
                throw DeserializerError.EntityNotFound("Event type with id \(eventTypeId) not found on deserializer storage")
            }
            eventType = check
        }
        else {
            try validateRequiredFields(["id"], inJson: json)

            eventType = super.deserialize(json) as EventType
            if(!self.deserializerStorage.exist(eventType)) {
                deserializerStorage.add(eventType)
            }
            
            assert(!eventType.name.isEmpty)
        }
        
        return eventType
    }
}
