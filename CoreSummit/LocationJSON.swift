//
//  LocationJSON.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation

import SwiftFoundation

public extension Location {
    
    enum JSONKey: String {
        
        case id, name, description
    }
}

extension Location: JSONDecodable {
    
    public init?(JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.rawValue as? Int,
            let name = JSONObject[JSONKey.name.rawValue]?.rawValue as? String,
            let description = JSONObject[JSONKey.description.rawValue]?.rawValue as? String
            else { return nil }
        
        self.identifier = identifier
        self.name = name
        self.descriptionText = description
    }
}
