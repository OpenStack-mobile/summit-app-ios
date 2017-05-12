//
//  SummitJSON.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 5/31/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import JSON
import struct Foundation.URL

public extension Summit {
    
    enum JSONKey: String {
        
        case id, name, start_date, end_date, schedule_start_date, time_zone, dates_label, logo, active, start_showing_venues_date, sponsors, summit_types, ticket_types, event_types, tracks, track_groups, locations, speakers, schedule, timestamp, page_url, wifi_connections
    }
}

extension Summit: JSONDecodable {
    
    public init?(json JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.integerValue,
            let name = JSONObject[JSONKey.name.rawValue]?.rawValue as? String,
            let startDate = JSONObject[JSONKey.start_date.rawValue]?.integerValue,
            let endDate = JSONObject[JSONKey.end_date.rawValue]?.integerValue,
            let timeZoneJSON = JSONObject[JSONKey.time_zone.rawValue],
            let timeZone = TimeZone(json: timeZoneJSON),
            let active = JSONObject[JSONKey.active.rawValue]?.rawValue as? Bool,
            let sponsorsJSONArray = JSONObject[JSONKey.sponsors.rawValue]?.arrayValue,
            let sponsors = Company.from(json: sponsorsJSONArray),
            let speakersJSONArray = JSONObject[JSONKey.speakers.rawValue]?.arrayValue,
            let speakers = Speaker.from(json: speakersJSONArray),
            let ticketTypeJSONArray = JSONObject[JSONKey.ticket_types.rawValue]?.arrayValue,
            let ticketTypes = TicketType.from(json: ticketTypeJSONArray),
            let locationsJSONArray = JSONObject[JSONKey.locations.rawValue]?.arrayValue,
            let locations = Location.from(json: locationsJSONArray),
            let tracksJSONArray = JSONObject[JSONKey.tracks.rawValue]?.arrayValue,
            let tracks = Track.from(json: tracksJSONArray),
            let trackGroupsJSONArray = JSONObject[JSONKey.track_groups.rawValue]?.arrayValue,
            let trackGroups = TrackGroup.from(json: trackGroupsJSONArray),
            let eventsJSONArray = JSONObject[JSONKey.schedule.rawValue]?.arrayValue,
            let events = Event.from(json: eventsJSONArray, summit: identifier),
            let eventTypesJSONArray = JSONObject[JSONKey.event_types.rawValue]?.arrayValue,
            let eventTypes = EventType.from(json: eventTypesJSONArray),
            let webpage = JSONObject[JSONKey.page_url.rawValue]?.urlValue,
            let wirelessNetworksJSONArray = JSONObject[JSONKey.wifi_connections.rawValue]?.arrayValue,
            let wirelessNetworks = WirelessNetwork.from(json: wirelessNetworksJSONArray)
            else { return nil }
        
        self.identifier = identifier
        self.name = name
        self.start = Date(timeIntervalSince1970: TimeInterval(startDate))
        self.end = Date(timeIntervalSince1970: TimeInterval(endDate))
        self.timeZone = timeZone.name
        self.webpage = webpage
        self.active = active
        self.ticketTypes = Set(ticketTypes)
        self.tracks = Set(tracks)
        self.trackGroups = Set(trackGroups)
        self.schedule = Set(events)
        self.eventTypes = Set(eventTypes)
        self.speakers = Set(speakers)
        self.sponsors = Set(sponsors)
        self.wirelessNetworks = Set(wirelessNetworks)
        
        // filter venues (we have to ignore other types of venues)
        self.locations = Set(locations.filter({
            
            switch $0 {
                
            case let .venue(venue): return venue.type == .SummitVenue || venue.type == .SummitExternalLocation
                
            case .room: return true
            }
        }))
        
        // optional values
        
        self.datesLabel = JSONObject[JSONKey.dates_label.rawValue]?.rawValue as? String
        
        if let startShowingVenuesDate = JSONObject[JSONKey.start_showing_venues_date.rawValue]?.integerValue {
            
            self.startShowingVenues = Date(timeIntervalSince1970: TimeInterval(startShowingVenuesDate))
            
        } else {
            
            self.startShowingVenues = nil
        }
        
        if let scheduleStartDate = JSONObject[JSONKey.schedule_start_date.rawValue]?.integerValue {
            
            self.defaultStart = Date(timeIntervalSince1970: TimeInterval(scheduleStartDate))
            
        } else {
            
            self.defaultStart = nil
        }
    }
}
