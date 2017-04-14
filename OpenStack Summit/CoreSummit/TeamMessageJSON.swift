//
//  TeamMessageJSON.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 12/28/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import JSON

public extension TeamMessage {
    
    enum JSONKey: String {
        
        case id, team_id, body, created_at, from_id
    }
}

extension TeamMessage: JSONDecodable {
    
    public init?(json JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.integerValue,
            let teamIdentifier = JSONObject[JSONKey.team_id.rawValue]?.integerValue,
            let fromMemberIdentifier = JSONObject[JSONKey.from_id.rawValue]?.integerValue,
            let body = JSONObject[JSONKey.body.rawValue]?.rawValue as? String,
            let created = JSONObject[JSONKey.created_at.rawValue]?.integerValue
            else { return nil }
        
        self.identifier = identifier
        self.body = body
        self.created = Date(timeIntervalSince1970: TimeInterval(created))
        self.team = .identifier(teamIdentifier)
        self.from = .identifier(fromMemberIdentifier)
    }
}
