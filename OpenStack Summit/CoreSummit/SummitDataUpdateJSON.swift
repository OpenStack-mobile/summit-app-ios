//
//  SummitDataUpdateJSON.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/16/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import struct Foundation.Date
import JSON

extension Summit.DataUpdate {
    
    typealias JSONKey = Summit.JSONKey
}

extension Summit.DataUpdate: JSONDecodable {
    
    public init?(json JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.integerValue,
            let name = JSONObject[JSONKey.name.rawValue]?.rawValue as? String,
            let startDate = JSONObject[JSONKey.start_date.rawValue]?.integerValue,
            let endDate = JSONObject[JSONKey.end_date.rawValue]?.integerValue,
            let timeZoneJSON = JSONObject[JSONKey.time_zone.rawValue],
            let timeZone = TimeZone(json: timeZoneJSON),
            let ticketTypeJSONArray = JSONObject[JSONKey.ticket_types.rawValue]?.arrayValue,
            let ticketTypes = TicketType.from(json: ticketTypeJSONArray),
            let locationsJSONArray = JSONObject[JSONKey.locations.rawValue]?.arrayValue,
            let locations = Location.from(json: locationsJSONArray),
            let webpageURL = JSONObject[JSONKey.page_url.rawValue]?.rawValue as? String,
            let active = JSONObject[JSONKey.active.rawValue]?.rawValue as? Bool
            else { return nil }
        
        self.identifier = identifier
        self.name = name
        self.start = Date(timeIntervalSince1970: TimeInterval(startDate))
        self.end = Date(timeIntervalSince1970: TimeInterval(endDate))
        self.timeZone = timeZone.name // should store entire timeZone struct and not just name, but Realm doesnt
        self.ticketTypes = Set(ticketTypes)
        self.webpageURL = webpageURL
        self.active = active
        
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
    }
}
