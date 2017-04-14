//
//  TeamJSON.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 12/28/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import JSON

public extension Team {
    
    enum JSONKey: String {
        
        case id, name, description, created_at, updated_at, owner, members, invitations
    }
}

extension Team: JSONDecodable {
    
    public init?(json JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.integerValue,
            let encodedName = JSONObject[JSONKey.name.rawValue]?.rawValue as? String,
            let name = String(openStackEncoded: encodedName),
            let created = JSONObject[JSONKey.created_at.rawValue]?.integerValue,
            let updated = JSONObject[JSONKey.updated_at.rawValue]?.integerValue,
            let ownerJSON = JSONObject[JSONKey.owner.rawValue],
            let owner = Member(json: ownerJSON),
            let membersJSONArray = JSONObject[JSONKey.members.rawValue]?.arrayValue,
            let members = TeamMember.from(json: membersJSONArray)
            else { return nil }
        
        self.identifier = identifier
        self.name = name
        self.created = Date(timeIntervalSince1970: TimeInterval(created))
        self.updated = Date(timeIntervalSince1970: TimeInterval(updated))
        self.owner = owner
        self.members = Set(members)
        
        // optional
        if let encodedDescriptionText = JSONObject[JSONKey.description.rawValue]?.rawValue as? String,
            let descriptionText = String(openStackEncoded: encodedDescriptionText) {
            
            self.descriptionText = descriptionText
            
        } else {
            
            self.descriptionText = nil
        }
        
        if let invitationsJSONArray = JSONObject[JSONKey.invitations.rawValue]?.arrayValue {
            
            guard let invitations = TeamInvitation.from(json: invitationsJSONArray)
                else { return nil }
            
            self.invitations = Set(invitations)
            
        } else {
            
            self.invitations = []
        }
        
    }
}
