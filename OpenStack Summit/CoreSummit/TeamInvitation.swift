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
    
    public let team: Team
    
    public let inviter: Member
    
    public let invitee: Member
    
    public let permission: TeamPermission
    
    public let created: Date
}

// MARK: - Equatable

public func == (lhs: TeamInvitation, rhs: TeamInvitation) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.team == rhs.team
        && lhs.inviter == rhs.inviter
        && lhs.invitee == rhs.invitee
        && lhs.permission == rhs.permission
        && lhs.created == rhs.created
}
