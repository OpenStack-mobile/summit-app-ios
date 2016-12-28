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
        
        case permission
    }
}

extension TeamMember: JSONParametrizedDecodable {
    
    public init?(JSONValue: JSON.Value, parameters: (team: Identifier, membership: TeamMembership)) {
        
        guard let JSONObject = JSONValue.objectValue,
            let permissionString = JSONObject[JSONKey.permission.rawValue]?.rawValue as? String,
            let permission = TeamPermission(rawValue: permissionString),
            let member = Member(JSONValue: JSONValue)
            else { return nil }
        
        self.member = member
        self.permission = permission
        
        // not really from JSON
        self.team = parameters.team
        self.membership = parameters.membership
    }
}
