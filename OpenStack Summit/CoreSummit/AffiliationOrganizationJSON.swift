//
//  AffiliationOrganizationJSON.swift
//  OpenStack Summit
//
//  Created by Gabriel Horacio Cutrini on 3/24/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import SwiftFoundation

public extension AffiliationOrganization {
    
    enum JSONKey: String {
        
        case id, name
    }
}

extension AffiliationOrganization: JSONDecodable {
    
    public init?(JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.rawValue as? Int,
            let name = JSONObject[JSONKey.name.rawValue]?.rawValue as? String
            else { return nil }
        
        self.identifier = identifier
        self.name = name
    }
}
