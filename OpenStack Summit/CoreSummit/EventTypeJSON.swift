//
//  EventTypeJSON.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import JSON

public extension EventType {
    
    enum JSONKey: String {
        
        case id, name, color, black_out_times
    }
}

extension EventType: JSONDecodable {
    
    public init?(json JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.integerValue,
            let name = JSONObject[JSONKey.name.rawValue]?.rawValue as? String,
            let color = JSONObject[JSONKey.color.rawValue]?.rawValue as? String,
            let blackOutTimes = JSONObject[JSONKey.black_out_times.rawValue]?.rawValue as? Bool
            else { return nil }
        
        self.identifier = identifier
        self.name = name
        self.color = color
        self.blackOutTimes = blackOutTimes
    }
}
