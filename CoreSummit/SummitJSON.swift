//
//  SummitJSON.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 5/31/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

public extension Summit {
    
    enum JSONKey: String {
        
        case id, name, start_date, end_date, time_zone, logo, active, start_showing_venues_date, sponsors, summit_types, ticket_types, event_types, tracks, track_groups, locations, speakers, schedule, timestamp
    }
}

extension Summit: JSONDecodable {
    
    public init?(JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.rawValue as? Int,
            let name = JSONObject[JSONKey.name.rawValue]?.rawValue as? String,
            let startDate = JSONObject[JSONKey.start_date.rawValue]?.rawValue as? Int,
            let endDate = JSONObject[JSONKey.end_date.rawValue]?.rawValue as? Int,
            let timeZoneJSON = JSONObject[JSONKey.time_zone.rawValue],
            let timeZone = TimeZone(JSONValue: timeZoneJSON),
            /* let timestamp = JSONObject[JSONKey.timestamp.rawValue]?.rawValue as? Int, */
            /* let active = JSONObject[JSONKey.active.rawValue]?.rawValue as? Bool, */
            /* let sponsorsJSONArray = JSONObject[JSONKey.sponsors.rawValue]?.arrayValue, */
            /* let sponsors = Company.fromJSON(sponsorsJSONArray), */
            /* let speakersJSONArray = JSONObject[JSONKey.speakers.rawValue]?.arrayValue, */
            /* let speakers = PresentationSpeaker.fromJSON(speakersJSONArray), */
            let summitTypesJSONArray = JSONObject[JSONKey.summit_types.rawValue]?.arrayValue,
            let summitTypes = SummitType.fromJSON(summitTypesJSONArray),
            let ticketTypeJSONArray = JSONObject[JSONKey.ticket_types.rawValue]?.arrayValue,
            let ticketTypes = TicketType.fromJSON(ticketTypeJSONArray),
            let locationsJSONArray = JSONObject[JSONKey.locations.rawValue]?.arrayValue,
            let locations = Location.fromJSON(locationsJSONArray),
            let tracksJSONArray = JSONObject[JSONKey.tracks.rawValue]?.arrayValue,
            let tracks = Track.fromJSON(tracksJSONArray),
            let trackGroupsJSONArray = JSONObject[JSONKey.track_groups.rawValue]?.arrayValue,
            let trackGroups = TrackGroup.fromJSON(trackGroupsJSONArray),
            let eventsJSONArray = JSONObject[JSONKey.schedule.rawValue]?.arrayValue,
            let events = SummitEvent.fromJSON(eventsJSONArray),
            let eventTypesJSONArray = JSONObject[JSONKey.event_types.rawValue]?.arrayValue,
            let eventTypes = EventType.fromJSON(eventTypesJSONArray)
            else { return nil }
        
        self.identifier = identifier
        self.name = name
        self.start = Date(timeIntervalSince1970: TimeInterval(startDate))
        self.end = Date(timeIntervalSince1970: TimeInterval(endDate))
        self.timeZone = timeZone.name // should store entire timeZone struct and not just name, but Realm doesnt
        self.summitTypes = summitTypes
        self.ticketTypes = ticketTypes
        self.locations = locations
        self.tracks = tracks
        self.trackGroups = trackGroups
        self.schedule = events
        self.eventTypes = eventTypes
        
        // in JSON but not in Realm
        //self.timestamp = Date(timeIntervalSince1970: TimeInterval(timestamp))
        //self.active = active
        //self.sponsors = sponsors
        //self.speakers = speakers
        
        // optional values
        
        if let startShowingVenuesDate = JSONObject[JSONKey.start_showing_venues_date.rawValue]?.rawValue as? Int {
            
            self.startShowingVenues = Date(timeIntervalSince1970: TimeInterval(startShowingVenuesDate))
            
        } else {
            
            self.startShowingVenues = nil
        }
    }
}
