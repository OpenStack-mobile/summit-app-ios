//
//  TeamJSON.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 12/28/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

public extension Team {
    
    enum JSONKey: String {
        
        case id, name, description, created_at, updated_at, owner, members
    }
}

extension Team: JSONDecodable {
    
    public init?(JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.rawValue as? Int,
            let name = JSONObject[JSONKey.name.rawValue]?.rawValue as? String,
            let descriptionText = JSONObject[JSONKey.description.rawValue]?.rawValue as? String,
            let created = JSONObject[JSONKey.created_at.rawValue]?.rawValue as? Int,
            let updated = JSONObject[JSONKey.updated_at.rawValue]?.rawValue as? Int,
            let ownerJSON = JSONObject[JSONKey.owner.rawValue],
            let owner = TeamMember(JSONValue: ownerJSON),
            let membersJSONArray = JSONObject[JSONKey.members.rawValue]?.arrayValue,
            let members = TeamMember.fromJSON(membersJSONArray)
            else { return nil }
        
        self.identifier = identifier
        self.name = name
        self.descriptionText = descriptionText
        self.created = Date(timeIntervalSince1970: TimeInterval(created))
        self.updated = Date(timeIntervalSince1970: TimeInterval(updated))
        self.owner = owner
        self.members = Set(members)
    }
}
