//
//  TeamInvitation.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 1/2/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import SwiftFoundation

public struct TeamInvitation<TeamFault: FaultConvertible where TeamFault.Value == Team>: Unique {
    
    public let identifier: Identifier
    
    public let team: TeamFault
    
    public let inviter: Member
    
    public let invitee: Member
    
    public let permission: TeamPermission
    
    public let created: Date
    
    public var updated: Date
    
    public var accepted: Bool
}

// MARK: - Equatable

public func == <TeamFault: FaultConvertible> (lhs: TeamInvitation<TeamFault>, rhs: TeamInvitation<TeamFault>) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.team == rhs.team
        && lhs.inviter == rhs.inviter
        && lhs.invitee == rhs.invitee
        && lhs.permission == rhs.permission
        && lhs.created == rhs.created
        && lhs.updated == rhs.updated
        && lhs.accepted == rhs.accepted
}
