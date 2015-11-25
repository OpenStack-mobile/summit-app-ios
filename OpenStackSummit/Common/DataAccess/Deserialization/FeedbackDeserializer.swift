//
//  FeedbackDeserializer.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/16/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON

public class FeedbackDeserializer: NSObject, IDeserializer {
    var deserializerFactory: DeserializerFactory!
    var deserializerStorage: DeserializerStorage!
    
    public func deserialize(json: JSON) throws -> BaseEntity {
        let feedback : Feedback
        
        if let feedbackId = json.int {
            feedback = deserializerStorage.get(feedbackId)
        }
        else {
            try validateRequiredFields(["id", "rate", "created_date", "event_id"], inJson: json)

            feedback = Feedback()
            feedback.id = json["id"].intValue
            feedback.rate = json["rate"].intValue
            feedback.review = json["note"].stringValue
            feedback.date = NSDate(timeIntervalSince1970: NSTimeInterval(json["created_date"].intValue))
            
            var deserializer = deserializerFactory.create(DeserializerFactoryType.SummitEvent)
            feedback.event = try deserializer.deserialize(json["event_id"]) as! SummitEvent

            deserializer = deserializerFactory.create(DeserializerFactoryType.SummitAttendee)

            if json["atendee_id"] != nil {
                feedback.owner = try deserializer.deserialize(json["attendee_id"]) as! SummitAttendee
            }
            else if json["owner_id"] != nil {
                feedback.owner = try deserializer.deserialize(json["owner_id"]) as! SummitAttendee

            }
            else if json["owner"] != nil {
                feedback.owner = try deserializer.deserialize(json["owner"]) as! SummitAttendee
            }
            else {
                throw DeserializerError.BadFormat("Can't deserialize feedback owner")
            }
            
            if(!deserializerStorage.exist(feedback)) {
                deserializerStorage.add(feedback)
            }
        }
        
        return feedback
    }
}
