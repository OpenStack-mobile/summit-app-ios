//
//  TeamInvitationJSON.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 1/2/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import SwiftFoundation

public extension TeamInvitation {
    
    enum JSONKey: String {
        
        case id, team_id, invitee_id, inviter_id, permissions, created_at
    }
}

extension TeamInvitation: JSONDecodable {
    
    public init?(JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.rawValue as? Int,
            let team = JSONObject[JSONKey.team_id.rawValue]?.rawValue as? Int,
            let invitee = JSONObject[JSONKey.invitee_id.rawValue]?.rawValue as? Int,
            let inviter = JSONObject[JSONKey.inviter_id.rawValue]?.rawValue as? Int,
            let permissionString = JSONObject[JSONKey.permissions.rawValue]?.rawValue as? String,
            let permission = TeamPermission(rawValue: permissionString),
            let created = JSONObject[JSONKey.created_at.rawValue]?.rawValue as? Int
            else { return nil }
        
        self.identifier = identifier
        self.team = team
        self.invitee = invitee
        self.inviter = inviter
        self.permission = permission
        self.created = Date(timeIntervalSince1970: TimeInterval(created))
    }
}
