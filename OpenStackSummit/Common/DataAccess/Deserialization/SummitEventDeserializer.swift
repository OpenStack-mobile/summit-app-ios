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
    
    public func deserialize(json: JSON) -> BaseEntity {
        var summitEvent = SummitEvent()
        
        if let eventId = json.int {
            summitEvent = deserializerStorage.get(eventId)
        }
        else {
            summitEvent.id = json["id"].intValue
            summitEvent.start = NSDate(timeIntervalSince1970: NSTimeInterval(json["start_date"].intValue))
            summitEvent.end = NSDate(timeIntervalSince1970: NSTimeInterval(json["end_date"].intValue))
            summitEvent.title = json["title"].stringValue
            summitEvent.eventDescription = json["description"].stringValue
            
            var deserializer = deserializerFactory.create(DeserializerFactories.EventType)
            summitEvent.eventType = deserializer.deserialize(json["type_id"]) as! EventType
            
            deserializer = deserializerFactory.create(DeserializerFactories.SummitType)
            var summitType : SummitType
            for (_, summitTypeJSON) in json["summit_types"] {
                summitType = deserializer.deserialize(summitTypeJSON) as! SummitType
                summitEvent.summitTypes.append(summitType)
            }
            
            deserializer = deserializerFactory.create(DeserializerFactories.Company)
            var company : Company
            for (_, companyJSON) in json["sponsors"] {
                company = deserializer.deserialize(companyJSON) as! Company
                summitEvent.sponsors.append(company)
            }
            
            let trackId = json["track_id"]
            if (trackId.int != nil) {
                deserializer = deserializerFactory.create(DeserializerFactories.Presentation)
                let presentation = deserializer.deserialize(json) as! Presentation
                
                summitEvent.presentation = presentation

                deserializer = deserializerFactory.create(DeserializerFactories.Venue)
                summitEvent.venue = deserializer.deserialize(json["location_id"]) as? Venue
                
                /*deserializer = deserializerFactory.create(DeserializerFactories.VenueRoom)
                summitEvent.venueRoom = deserializer.deserialize(json["location_id"]) as? VenueRoom*/
            }
            else {
                deserializer = deserializerFactory.create(DeserializerFactories.Venue)
                summitEvent.venue = deserializer.deserialize(json["location_id"]) as? Venue
            }
            deserializerStorage.add(summitEvent)
        }
        
        return summitEvent
    }
}
