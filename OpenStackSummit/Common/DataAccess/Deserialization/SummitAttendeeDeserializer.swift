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
    
    public init(deserializerStorage: DeserializerStorage, deserializerFactory: DeserializerFactory) {
        self.deserializerStorage = deserializerStorage
        self.deserializerFactory = deserializerFactory
    }
    
    public override init() {
        super.init()
    }
    
    public func deserialize(json : JSON) throws -> BaseEntity {
        
        let summitAttendee: SummitAttendee
        
        if let summitAttendeeId = json.int {
            guard let check: SummitAttendee = deserializerStorage.get(summitAttendeeId) else {
                throw DeserializerError.EntityNotFound("Summit attendee with id \(summitAttendeeId) not found on deserializer storage")
            }
            summitAttendee = check
        }
        else {
            try validateRequiredFields(["id", "first_name", "last_name"], inJson: json)
            
            summitAttendee = SummitAttendee()
            summitAttendee.id = json["id"].intValue
            summitAttendee.firstName = json["first_name"].stringValue
            summitAttendee.lastName = json["last_name"].stringValue
            summitAttendee.fullName = summitAttendee.firstName + " " + summitAttendee.lastName
            summitAttendee.title = json["title"].stringValue
            summitAttendee.email = json["email"].stringValue
            summitAttendee.irc = json["irc"].string ?? ""
            summitAttendee.twitter = json["twitter"].string ?? ""
            summitAttendee.bio = json["bio"].stringValue
            summitAttendee.pictureUrl = json["pic"].stringValue
            
            var deserializer = deserializerFactory.create(DeserializerFactoryType.SummitEvent)
            var event : SummitEvent
            for (_, eventJSON) in json["schedule"] {
                do {
                    event = try deserializer.deserialize(eventJSON) as! SummitEvent
                    summitAttendee.scheduledEvents.append(event)
                } catch let error {
                    print(error)
                }
            }
            
            deserializer = deserializerFactory.create(DeserializerFactoryType.TicketType)
            var ticketType: TicketType
            for (_, ticketJSON) in json["tickets"] {
                ticketType = try deserializer.deserialize(ticketJSON) as! TicketType
                summitAttendee.tickets.append(ticketType)
            }
            
            if(!deserializerStorage.exist(summitAttendee)) {
                deserializerStorage.add(summitAttendee)
            }
            
            deserializer = deserializerFactory.create(DeserializerFactoryType.Feedback)
            var feedback : Feedback
            for (_, feedbackJSON) in json["feedback"] {
                feedback = try deserializer.deserialize(feedbackJSON) as! Feedback
                summitAttendee.feedback.append(feedback)
            }
        }
        
        return summitAttendee
    }
}
