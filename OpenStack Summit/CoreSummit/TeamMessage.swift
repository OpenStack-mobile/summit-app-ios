//
//  TeamMessage.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 12/27/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation

public struct TeamMessage: Unique {
    
    public let identifier: Identifier
    
    public let team: Fault<Team>
    
    public let body: String
    
    public let created: Date
    
    public let from: Fault<Member>
}

// MARK: - Equatable

public func == (lhs: TeamMessage, rhs: TeamMessage) -> Bool {
    
    return lhs.identifier == rhs.identifier &&
        lhs.team == rhs.team &&
        lhs.body == rhs.body &&
        lhs.created == rhs.created &&
        lhs.from == rhs.from
}
