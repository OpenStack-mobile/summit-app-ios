//
//  TeamMemberJSON.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 12/28/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

public extension TeamMember {
    
    enum JSONKey: String {
        
        case id, permission, team_id, member
    }
}

extension TeamMember: JSONDecodable {
    
    public init?(JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.rawValue as? Int,
            let team = JSONObject[JSONKey.team_id.rawValue]?.rawValue as? Int,
            let permissionString = JSONObject[JSONKey.permission.rawValue]?.rawValue as? String,
            let permission = TeamPermission(rawValue: permissionString),
            let memberJSON = JSONObject[JSONKey.member.rawValue],
            let member = Member(JSONValue: memberJSON)
            else { return nil }
        
        self.identifier = identifier
        self.team = team
        self.member = member
        self.permission = permission
    }
}
