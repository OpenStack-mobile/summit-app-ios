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
        var eventType: EventType
        for (_, eventTypeJSON) in json["event_types"] {
            eventType = try deserializer.deserialize(eventTypeJSON) as! EventType
            summit.eventTypes.append(eventType)
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
                
                let venueId = venueJSON["venue_id"].intValue
                guard let check: Venue = deserializerStorage.get(venueId) else {
                    throw DeserializerError.EntityNotFound("Venue with id \(venueId) not found on deserializer storage")
                }
                venue = check
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
        
        summit.id = json["id"].intValue
        summit.name = json["name"].stringValue
        summit.timeZone = json["time_zone"]["name"].stringValue
        summit.startDate = summit.events.first!.start
        summit.endDate = summit.events.last!.end
        summit.initialDataLoadDate = NSDate(timeIntervalSince1970: NSTimeInterval(json["timestamp"].intValue))
        
        return summit
    }
    
    /*func getDateInTimeZone(date: NSDate, timezone: String) -> NSDate {
        let timeZoneSeconds = NSTimeZone(name: timezone)!.secondsFromGMT;
        let dateInTimezone = date.dateByAddingTimeInterval(NSTimeInterval(timeZoneSeconds));
        return dateInTimezone
    }*/
    
    func isVenue(venueJSON: JSON) -> Bool {
        return venueJSON["class_name"].stringValue == "SummitVenue"
    }
    
    func isVenueRoom(venueJSON: JSON) -> Bool {
        return venueJSON["class_name"].stringValue == "SummitVenueRoom"
    }
}
