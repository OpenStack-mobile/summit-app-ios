//
//  SummitEventJSON.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

public extension SummitEvent {
    
    enum JSONKey: String {
        
        case id, name, start_date, end_date, type_id, summit_types, sponsors, speakers, location_id, tags, track_id
    }
}

extension SummitEvent: JSONDecodable {
    
    public init?(JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.rawValue as? Int,
            let name = JSONObject[JSONKey.name.rawValue]?.rawValue as? String,
            let startDate = JSONObject[JSONKey.start_date.rawValue]?.rawValue as? Int,
            let endDate = JSONObject[JSONKey.end_date.rawValue]?.rawValue as? Int,
            let eventType = JSONObject[JSONKey.type_id.rawValue]
            else { return nil }
    }
}