//
//  AffiliationJSON.swift
//  OpenStack Summit
//
//  Created by Gabriel Horacio Cutrini on 3/24/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import SwiftFoundation

public extension Affiliation {
    
    enum JSONKey: String {
        
        case id, owner_id, start_date, end_date, is_current, organization
    }
}

extension Affiliation: JSONDecodable {
    
    public init?(JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.rawValue as? Int,
            let isCurrent = JSONObject[JSONKey.is_current.rawValue]?.rawValue as? Bool,
            let organizationJSON = JSONObject[JSONKey.organization.rawValue],
            let organization = AffiliationOrganization(JSONValue: organizationJSON),
            let member = JSONObject[JSONKey.owner_id.rawValue]?.rawValue as? Int
            else { return nil }
        
        self.identifier = identifier
        self.isCurrent = isCurrent
        self.organization = organization
        self.member = member
        
        // optional values
        
        if let startDate = JSONObject[JSONKey.start_date.rawValue]?.rawValue as? Int {
            
            self.start = Date(timeIntervalSince1970: TimeInterval(startDate))
            
        } else {
            
            self.start = nil
        }

        if let endDate = JSONObject[JSONKey.end_date.rawValue]?.rawValue as? Int {
            
            self.end = Date(timeIntervalSince1970: TimeInterval(endDate))
            
        } else {
            
            self.end = nil
        }
    }
}
