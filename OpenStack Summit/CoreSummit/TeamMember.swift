//
//  TeamMember.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 12/27/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

public struct TeamMember: Equatable, Hashable {
    
    public var permission: PermissionType
    
    public var team: Identifier
    
    public var member: Member
    
    public var membership: Membership
}

// MARK: - Hashable

public extension TeamPermission {
    
    var hashValue: Int {
        
        return "\(type.hashValue),\(team.hashValue),\(member.hashValue),\(membership.hashValue)".hashValue
    }
}

// MARK: - Equatable

public func == (lhs: TeamPermission, rhs: TeamPermission) -> Bool {
    
    return lhs.type == rhs.type
        && lhs.team == rhs.team
        && lhs.membership == rhs.membership
}

// MARK: - Supporting Types

public enum PermissionType: String {
    
    case admin
    case read
    case write
}

public extension TeamPermission {
    
    public enum PermissionType: String {
        
        case admin
        case read
        case write
    }
    
    public enum Membership {
        
        case owner
        case member
    }
}
