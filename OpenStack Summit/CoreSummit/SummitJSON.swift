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
        
        case id, name, start_date, end_date, schedule_start_date, time_zone, dates_label, logo, active, start_showing_venues_date, sponsors, summit_types, ticket_types, event_types, tracks, track_groups, locations, speakers, schedule, timestamp, page_url, wifi_connections
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
            let active = JSONObject[JSONKey.active.rawValue]?.rawValue as? Bool,
            let sponsorsJSONArray = JSONObject[JSONKey.sponsors.rawValue]?.arrayValue,
            let sponsors = Company.fromJSON(sponsorsJSONArray),
            let speakersJSONArray = JSONObject[JSONKey.speakers.rawValue]?.arrayValue,
            let speakers = Speaker.fromJSON(speakersJSONArray),
            let ticketTypeJSONArray = JSONObject[JSONKey.ticket_types.rawValue]?.arrayValue,
            let ticketTypes = TicketType.fromJSON(ticketTypeJSONArray),
            let locationsJSONArray = JSONObject[JSONKey.locations.rawValue]?.arrayValue,
            let locations = Location.fromJSON(locationsJSONArray),
            let tracksJSONArray = JSONObject[JSONKey.tracks.rawValue]?.arrayValue,
            let tracks = Track.fromJSON(tracksJSONArray),
            let trackGroupsJSONArray = JSONObject[JSONKey.track_groups.rawValue]?.arrayValue,
            let trackGroups = TrackGroup.fromJSON(trackGroupsJSONArray),
            let eventsJSONArray = JSONObject[JSONKey.schedule.rawValue]?.arrayValue,
            let events = Event.fromJSON(eventsJSONArray, parameters: identifier),
            let eventTypesJSONArray = JSONObject[JSONKey.event_types.rawValue]?.arrayValue,
            let eventTypes = EventType.fromJSON(eventTypesJSONArray),
            let webpageURL = JSONObject[JSONKey.page_url.rawValue]?.rawValue as? String,
            let wirelessNetworksJSONArray = JSONObject[JSONKey.wifi_connections.rawValue]?.arrayValue,
            let wirelessNetworks = WirelessNetwork.fromJSON(wirelessNetworksJSONArray)
            else { return nil }
        
        self.identifier = identifier
        self.name = name
        self.start = Date(timeIntervalSince1970: TimeInterval(startDate))
        self.end = Date(timeIntervalSince1970: TimeInterval(endDate))
        self.timeZone = timeZone.name
        self.webpageURL = webpageURL
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
        
        if let startShowingVenuesDate = JSONObject[JSONKey.start_showing_venues_date.rawValue]?.rawValue as? Int {
            
            self.startShowingVenues = Date(timeIntervalSince1970: TimeInterval(startShowingVenuesDate))
            
        } else {
            
            self.startShowingVenues = nil
        }
        
        if let scheduleStartDate = JSONObject[JSONKey.schedule_start_date.rawValue]?.rawValue as? Int {
            
            self.defaultStart = Date(timeIntervalSince1970: TimeInterval(scheduleStartDate))
            
        } else {
            
            self.defaultStart = nil
        }
    }
}
