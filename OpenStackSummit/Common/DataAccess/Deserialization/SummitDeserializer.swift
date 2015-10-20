//
//  SummitDeserializer.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/16/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//
import UIKit
import SwiftyJSON

public class SummitDeserializer: NSObject, IDeserializer {
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
        let summit = Summit()
        
        try validateRequiredFields(["id", "name", "start_date", "end_date", "time_zone", "sponsors", "summit_types", "ticket_types", "event_types", "tracks", "locations", "speakers", "schedule"], inJson: json)
        
        summit.id = json["id"].intValue
        summit.name = json["name"].stringValue
        summit.startDate = NSDate(timeIntervalSince1970: NSTimeInterval(json["start_date"].intValue))
        summit.endDate = NSDate(timeIntervalSince1970: NSTimeInterval(json["end_date"].intValue))
        summit.timeZone = json["time_zone"]["name"].stringValue

        var deserializer : IDeserializer!
        
        deserializer = deserializerFactory.create(DeserializerFactoryType.Company)
        for (_, companyJSON) in json["sponsors"] {
            try deserializer.deserialize(companyJSON)
        }
        
        deserializer = deserializerFactory.create(DeserializerFactoryType.SummitType)
        var summitType : SummitType
        for (_, summitTypeJSON) in json["summit_types"] {
            summitType = try deserializer.deserialize(summitTypeJSON) as! SummitType
            summit.types.append(summitType)
        }
        
        deserializer = deserializerFactory.create(DeserializerFactoryType.TicketType)
        var ticketType : TicketType
        for (_, ticketTypeJSON) in json["ticket_types"] {
            ticketType = try deserializer.deserialize(ticketTypeJSON) as! TicketType
            summit.ticketTypes.append(ticketType)
        }
        
        deserializer = deserializerFactory.create(DeserializerFactoryType.EventType)
        for (_, eventTypeJSON) in json["event_types"] {
            try deserializer.deserialize(eventTypeJSON)
        }
        
        deserializer = deserializerFactory.create(DeserializerFactoryType.Track)
        for (_, presentationCategoryJSON) in json["tracks"] {
            try deserializer.deserialize(presentationCategoryJSON)
        }

        deserializer = deserializerFactory.create(DeserializerFactoryType.Venue)
        var venue: Venue
        for (_, venueJSON) in json["locations"] {
            if (isVenue(venueJSON)) {
                venue = try deserializer.deserialize(venueJSON) as! Venue
                summit.venues.append(venue)
            }
        }

        deserializer = deserializerFactory.create(DeserializerFactoryType.VenueRoom)
        var venueRoom: VenueRoom
        for (_, venueJSON) in json["locations"] {
            if (isVenueRoom(venueJSON)) {
                venueRoom = try deserializer.deserialize(venueJSON) as! VenueRoom
                venue = deserializerStorage.get(venueJSON["venue_id"].intValue)
                venue.venueRooms.append(venueRoom)
            }
        }
        
        deserializer = deserializerFactory.create(DeserializerFactoryType.PresentationSpeaker)
        for (_, presentationSpeakerJSON) in json["speakers"] {
            try deserializer.deserialize(presentationSpeakerJSON) as! PresentationSpeaker
        }
        
        var event : SummitEvent
        for (_, eventJSON) in json["schedule"] {

            deserializer = deserializerFactory.create(DeserializerFactoryType.SummitEvent)
            event = try deserializer.deserialize(eventJSON) as! SummitEvent
            summit.events.append(event)
        }
        
        return summit
    }
    
    func isVenue(venueJSON: JSON) -> Bool {
        return venueJSON["class_name"].stringValue == "SummitVenue"
    }
    
    func isVenueRoom(venueJSON: JSON) -> Bool {
        return venueJSON["class_name"].stringValue == "SummitVenueRoom"
    }
}
