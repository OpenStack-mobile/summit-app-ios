//
//  SummitDataUpdateJSON.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/16/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

public extension SummitDataUpdate {
    
    typealias JSONKey = Summit.JSONKey
}

extension SummitDataUpdate: JSONDecodable {
    
    public init?(JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.rawValue as? Int,
            let name = JSONObject[JSONKey.name.rawValue]?.rawValue as? String,
            let startDate = JSONObject[JSONKey.start_date.rawValue]?.rawValue as? Int,
            let endDate = JSONObject[JSONKey.end_date.rawValue]?.rawValue as? Int,
            let timeZoneJSON = JSONObject[JSONKey.time_zone.rawValue],
            let timeZone = TimeZone(JSONValue: timeZoneJSON),
            let ticketTypeJSONArray = JSONObject[JSONKey.ticket_types.rawValue]?.arrayValue,
            let ticketTypes = TicketType.fromJSON(ticketTypeJSONArray),
            let locationsJSONArray = JSONObject[JSONKey.locations.rawValue]?.arrayValue,
            let locations = Location.fromJSON(locationsJSONArray),
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
        
        if let startShowingVenuesDate = JSONObject[JSONKey.start_showing_venues_date.rawValue]?.rawValue as? Int {
            
            self.startShowingVenues = Date(timeIntervalSince1970: TimeInterval(startShowingVenuesDate))
            
        } else {
            
            self.startShowingVenues = nil
        }
    }
}
