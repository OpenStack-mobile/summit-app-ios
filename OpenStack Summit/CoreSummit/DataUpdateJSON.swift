//
//  DataUpdateJSON.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 8/8/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import struct Foundation.Date
import JSON

public extension DataUpdate {
    
    enum JSONKey: String {
        
        case id, class_name, type, entity, entity_id, created
    }
}

extension DataUpdate: JSONDecodable {
    
    public init?(json JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.integerValue,
            let created = JSONObject[JSONKey.created.rawValue]?.integerValue,
            let classNameString = JSONObject[JSONKey.class_name.rawValue]?.rawValue as? String,
            let className = ClassName(rawValue: classNameString),
            let typeString = JSONObject[JSONKey.type.rawValue]?.rawValue as? String,
            let operation = Operation(rawValue: typeString)
            else { return nil }
        
        self.identifier = identifier
        self.operation = operation
        self.date = Date(timeIntervalSince1970: TimeInterval(created))
        self.className = className
        
        if let entityJSON = JSONObject[JSONKey.entity.rawValue]?.objectValue {
            
            self.entity = .json(entityJSON)
            
        } else if let entityID = JSONObject[JSONKey.entity_id.rawValue]?.integerValue {
            
            self.entity = .identifier(entityID)
            
        } else {
            
            self.entity = nil
        }
    }
}
