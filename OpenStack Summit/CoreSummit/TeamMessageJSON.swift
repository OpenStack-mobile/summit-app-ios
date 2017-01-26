//
//  TeamMessageJSON.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 12/28/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

public extension TeamMessage {
    
    enum JSONKey: String {
        
        case id, team_id, body, created_at, from_id
    }
}

extension TeamMessage: JSONDecodable {
    
    public init?(JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.rawValue as? Int,
            let teamIdentifier = JSONObject[JSONKey.team_id.rawValue]?.rawValue as? Int,
            let fromMemberIdentifier = JSONObject[JSONKey.from_id.rawValue]?.rawValue as? Int,
            let body = JSONObject[JSONKey.body.rawValue]?.rawValue as? String,
            let created = JSONObject[JSONKey.created_at.rawValue]?.rawValue as? Int
            else { return nil }
        
        self.identifier = identifier
        self.body = body
        self.created = Date(timeIntervalSince1970: TimeInterval(created))
        self.team = .identifier(teamIdentifier)
        self.from = .identifier(fromMemberIdentifier)
    }
}
