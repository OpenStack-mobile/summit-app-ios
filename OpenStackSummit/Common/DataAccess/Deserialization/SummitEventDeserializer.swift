//
//  SummitEventDeserializer.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/18/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON

public class SummitEventDeserializer: NSObject, IDeserializer {
    var deserializerFactory: DeserializerFactory!
    var deserializerStorage: DeserializerStorage!
    
    public init(deserializerStorage: DeserializerStorage, deserializerFactory: DeserializerFactory) {
        self.deserializerStorage = deserializerStorage
        self.deserializerFactory = deserializerFactory
    }
    
    public override init() {
        super.init()
    }
    
    public func deserialize(json: JSON) throws -> BaseEntity {
        var summitEvent = SummitEvent()
        
        if let eventId = json.int {
            summitEvent = deserializerStorage.get(eventId)
        }
        else {
            try validateRequiredFields(["id", "start_date", "end_date", "title", "allow_feedback", "type_id"], inJson: json)
            
            summitEvent.id = json["id"].intValue
            summitEvent.start = NSDate(timeIntervalSince1970: NSTimeInterval(json["start_date"].intValue))
            summitEvent.end = NSDate(timeIntervalSince1970: NSTimeInterval(json["end_date"].intValue))
            summitEvent.name = json["title"].stringValue
            summitEvent.eventDescription = json["description"].stringValue
            summitEvent.allowFeedback = json["allow_feedback"].boolValue
            
            var deserializer = deserializerFactory.create(DeserializerFactoryType.EventType)
            summitEvent.eventType = try deserializer.deserialize(json["type_id"]) as! EventType

            deserializer = deserializerFactory.create(DeserializerFactoryType.SummitType)
            var summitType : SummitType
            for (_, summitTypeJSON) in json["summit_types"] {
                summitType = try deserializer.deserialize(summitTypeJSON) as! SummitType
                summitEvent.summitTypes.append(summitType)
            }
            
            deserializer = deserializerFactory.create(DeserializerFactoryType.Company)
            var company : Company
            for (_, companyJSON) in json["sponsors"] {
                company = try deserializer.deserialize(companyJSON) as! Company
                summitEvent.sponsors.append(company)
            }
            
            deserializer = deserializerFactory.create(DeserializerFactoryType.PresentationSpeaker)
            for (_, speakerJSON) in json["speakers"] {
                try deserializer.deserialize(speakerJSON) as! PresentationSpeaker
            }

            let locationId = json["location_id"]
            if (locationId.int != nil) {
                let venue = Venue()
                venue.id = locationId.intValue
                let venueRoom = VenueRoom()
                venueRoom.id = locationId.intValue
                
                if (deserializerStorage.exist(venue)){
                    deserializer = deserializerFactory.create(DeserializerFactoryType.Venue)
                    summitEvent.venue = try deserializer.deserialize(locationId) as? Venue
                }
                else if (deserializerStorage.exist(venueRoom)) {
                    deserializer = deserializerFactory.create(DeserializerFactoryType.VenueRoom)
                    summitEvent.venueRoom = try deserializer.deserialize(locationId) as? VenueRoom
                }
            }
            
            let trackId = json["track_id"]
            if (trackId.int != nil) {
                deserializer = deserializerFactory.create(DeserializerFactoryType.Presentation)
                let presentation = try deserializer.deserialize(json) as! Presentation
                
                summitEvent.presentation = presentation
            }

            deserializerStorage.add(summitEvent)
        }
        
        return summitEvent
    }
}
