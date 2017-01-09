//
//  TeamMember.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 12/27/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

public struct TeamMember: Equatable, Hashable {
    
    public var team: Identifier
    
    public var member: Member
    
    public var permission: TeamPermission
    
    public var membership: TeamMembership
}

// MARK: - Hashable

public extension TeamMember {
    
    var hashValue: Int {
        
        return "\(team.hashValue),\(member.hashValue),\(permission.hashValue),\(membership.hashValue)".hashValue
    }
}

// MARK: - Equatable

public func == (lhs: TeamMember, rhs: TeamMember) -> Bool {
    
    return lhs.team == rhs.team
        && lhs.member == rhs.member
        && lhs.permission == rhs.permission
        && lhs.membership == rhs.membership
}

// MARK: - Supporting Types

public enum TeamPermission: String {
    
    case admin  = "ADMIN"
    case read   = "READ"
    case write  = "WRITE"
}

public enum TeamMembership {
    
    case owner
    case member
}
