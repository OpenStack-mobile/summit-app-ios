//
//  CompanyJSON.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import JSON

public extension Company {
    
    enum JSONKey: String {
        
        case id, name
    }
}

extension Company: JSONDecodable {
    
    public init?(json JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.integerValue,
            let name = JSONObject[JSONKey.name.rawValue]?.rawValue as? String
            else { return nil }
        
        self.identifier = identifier
        self.name = name
    }
}
