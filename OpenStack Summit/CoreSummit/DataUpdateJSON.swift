//
//  DataUpdateJSON.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 8/8/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

public extension DataUpdate {
    
    enum JSONKey: String {
        
        case id, class_name, type
    }
}

extension DataUpdate: JSONDecodable {
    
    public init?(JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.rawValue as? Int,
            let className = JSONObject[JSONKey.class_name.rawValue]?.rawValue as? String,
            let entity = Entity(rawValue: className),
            let typeString = JSONObject[JSONKey.type.rawValue]?.rawValue as? String,
            let operation = Operation(rawValue: typeString)
            else { return nil }
        
        self.identifier = identifier
        self.entity = entity
        self.operation = operation
    }
}