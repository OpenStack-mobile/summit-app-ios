//
//  TeamPermission.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 12/27/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

public struct TeamPermission: Equatable, Hashable {
    
    public var type: PermissionType
    
    public var team: Identifier
    
    public var member: Member
}

// MARK: - Hashable

public extension TeamPermission {
    
    var hashValue: Int {
        
        return "\(type.hashValue),\(team.hashValue),\(member.hashValue)".hashValue
    }
}

// MARK: - Equatable

public func == (lhs: TeamPermission, rhs: TeamPermission) -> Bool {
    
    return lhs.type == rhs.type
        && lhs.team == rhs.team
        && lhs.member == rhs.member
}

// MARK: - Supporting Types

public extension TeamPermission {
    
    public enum PermissionType: String {
        
        case admin
        case read
        case write
    }
}
