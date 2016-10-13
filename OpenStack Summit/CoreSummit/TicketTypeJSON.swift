//
//  TicketTypeJSON.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

public extension TicketType {
    
    enum JSONKey: String {
        
        case id, name, allowed_summit_types, description
    }
}

extension TicketType: JSONDecodable {
    
    public init?(JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.rawValue as? Int,
            let name = JSONObject[JSONKey.name.rawValue]?.rawValue as? String,
            let allowedSummitTypesJSONArray = JSONObject[JSONKey.allowed_summit_types.rawValue]?.arrayValue,
            let allowedSummitTypes = Identifier.fromJSON(allowedSummitTypesJSONArray)
            else { return nil }
        
        self.identifier = identifier
        self.name = name
        self.allowedSummitTypes = allowedSummitTypes
        self.descriptionText = JSONObject[JSONKey.description.rawValue]?.rawValue as? String
    }
}