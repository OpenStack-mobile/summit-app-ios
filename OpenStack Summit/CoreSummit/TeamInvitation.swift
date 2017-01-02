//
//  TeamInvitation.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 1/2/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import SwiftFoundation

public struct TeamInvitation: Unique {
    
    public let identifier: Identifier
    
    public var team: Identifier
    
    public var owner: Identifier
    
    public var inviter: Identifier
    
    public var permission: TeamPermission
    
    public var created: Date
}

// MARK: - Equatable

public func == (lhs: TeamInvitation, rhs: TeamInvitation) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.team == rhs.team
        && lhs.owner == rhs.owner
        && lhs.inviter == rhs.inviter
        && lhs.permission == rhs.permission
        && lhs.created == rhs.created
}
