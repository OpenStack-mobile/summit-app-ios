//
//  EventTypeDeserializer.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/15/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON

public class EventTypeDeserializer: KeyValueDeserializer, DeserializerProtocol {
    var deserializerStorage: DeserializerStorage!
    
    public func deserialize(json : JSON) -> BaseEntity {
        let eventType : EventType
        
        if let eventTypeId = json.int {
            eventType = deserializerStorage.get(eventTypeId)
        }
        else {
            eventType = super.deserialize(json) as EventType
            if(!self.deserializerStorage.exist(eventType)) {
                deserializerStorage.add(eventType)
            }
        }
        
        return eventType
    }
}
