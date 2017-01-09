//
//  TeamMember.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 12/27/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

public struct TeamMember: Unique {
    
    public let identifier: Identifier
    
    public var team: Identifier
    
    public var member: Member
    
    public var permission: TeamPermission
}

// MARK: - Equatable

public func == (lhs: TeamMember, rhs: TeamMember) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.team == rhs.team
        && lhs.member == rhs.member
        && lhs.permission == rhs.permission
}

// MARK: - Supporting Types

public enum TeamPermission: String {
    
    case admin  = "ADMIN"
    case read   = "READ"
    case write  = "WRITE"
}
