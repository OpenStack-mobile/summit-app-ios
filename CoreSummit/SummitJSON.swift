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
        
        case id, name, start_date, end_date, time_zone, logo, active, start_showing_venues_date, sponsors, summit_types, ticket_types, event_types, tracks, track_groups, locations, speakers, schedule
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
            let summitTypesJSONArray = JSONObject[JSONKey.summit_types.rawValue]?.arrayValue,
            let summitTypes = SummitType.fromJSON(summitTypesJSONArray),
            let 
            else { return nil }
        
        self.identifier = identifier
        self.name = name
        self.start = Date(timeIntervalSince1970: TimeInterval(startDate))
        self.end = Date(timeIntervalSince1970: TimeInterval(endDate))
        self.timeZone = timeZone
        self.active = active
        self.summitTypes = summitTypes
        
        self.initialDataLoad = nil
        
        if let startShowingVenuesDate = jsonObject[JSONKey.start_showing_venues_date.rawValue]?.rawValue as? Int {
            
            self.startShowingVenues = Date(timeIntervalSince1970: TimeInterval(startShowingVenuesDate))
        }
        
        if let logo = jsonObject[JSONKey.logo.rawValue]?.rawValue as? String {
            
            self.logo = logo
        }
    }
}
