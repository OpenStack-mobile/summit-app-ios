//
//  Team.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 12/7/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

public struct Team: Named {
    
    public let identifier: Identifier
    
    public var name: String
    
    public var descriptionText: String?
    
    public var created: Date
    
    public var updated: Date
    
    public var owner: Member
    
    public var members: Set<TeamMember>
    
    public var invitations: Set<TeamInvitation>
}

// MARK: - Equatable

public func == (lhs: Team, rhs: Team) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.name == rhs.name
        && lhs.descriptionText == rhs.descriptionText
        && lhs.created == rhs.created
        && lhs.updated == rhs.updated
        && lhs.owner == rhs.owner
        && lhs.members == rhs.members
        && lhs.invitations == rhs.invitations
}

// MARK: - Extensions

public extension Team {
    
    func permission(for member: Identifier) -> TeamPermission? {
        
        if member == owner.identifier {
            
            return .admin
        }
        
        return members.firstMatching({ $0.member.identifier == member })?.permission
    }
}
