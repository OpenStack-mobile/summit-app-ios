//
//  TagJSON.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

public extension Tag {
    
    enum JSONKey: String {
        
        case id, tags
    }
}

extension Tag: JSONDecodable {
    
    public init?(JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.rawValue as? Int,
            let tags = JSONObject[JSONKey.tags.rawValue]?.rawValue as? String
            else { return nil }
        
        self.identifier = identifier
        self.name = tags
    }
}