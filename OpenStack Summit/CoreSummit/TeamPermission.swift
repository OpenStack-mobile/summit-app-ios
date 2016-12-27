//
//  TeamPermission.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 12/27/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

public struct TeamPermission: Equatable {
    
    public var type: PermissionType
    
    public var team: Identifier
    
    public var membership: Membership
}

// MARK: - Supporting Types

public extension TeamPermission {
    
    public enum PermissionType: String {
        
        case admin
        case read
        case write
    }
    
    public enum Membership: Equatable {
        
        case owner(TeamMember)
        case member(TeamMember)
    }
}

// MARK: - Equatable

public func == (lhs: TeamPermission, rhs: TeamPermission) -> Bool {
    
    return lhs.type == rhs.type
        && lhs.team == rhs.team
        && lhs.membership == rhs.membership
}

public func == (lhs: TeamPermission.Membership, rhs: TeamPermission.Membership) -> Bool {
    
    switch (lhs, rhs) {
    case let (.owner(lhsValue), .owner(rhsValue)): return lhsValue == rhsValue
    case let (.member(lhsValue), .member(rhsValue)): return lhsValue == rhsValue
    default: return false
    }
}
