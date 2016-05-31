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
        
        case id, name, start_date, end_date, time_zone, start_showing_venues_date, sponsors, summit_types, ticket_types, event_types, tracks, track_groups, locations, speakers, schedule
    }
}

extension Summit: JSONDecodable {
    
    public init?(JSONValue: JSON.Value) {
        
        guard let jsonObject = JSONValue.objectValue,
            let identifier = jsonObject[JSONKey.id.rawValue]?.rawValue as? Int,
            let name = jsonObject[JSONKey.name.rawValue]?.rawValue as? String,
            let startDate = jsonObject[JSONKey.start_date.rawValue]?.rawValue as? Int,
            let endDate = jsonObject[JSONKey.end_date.rawValue]?.rawValue as? Int,
            let timeZone = jsonObject[JSONKey.time_zone.rawValue]?.rawValue as? String,
            let startShowingVenuesDate = jsonObject[JSONKey.start_showing_venues_date.rawValue]?.rawValue as? Int
            else { return nil }
        
        self.identifier = identifier
        self.name = name
        self.start = Date(timeIntervalSince1970: TimeInterval(startDate))
        self.end = Date(timeIntervalSince1970: TimeInterval(endDate))
        self.timeZone = timeZone
        self.startShowingVenues = Date(timeIntervalSince1970: TimeInterval(startShowingVenuesDate))
        
        self.initialDataLoad = nil
    }
}