//
//  Affiliation.swift
//  OpenStack Summit
//
//  Created by Gabriel Horacio Cutrini on 3/23/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import struct SwiftFoundation.Date

public struct Affiliation: Unique, Equatable {
    
    public let identifier: Identifier
    
    public var member: Member
    
    public var start: Date?
    
    public var end: Date?
    
    public var isCurrent: Bool
    
    public var organization: AffiliationOrganization
}

// MARK: - Equatable

public func == (lhs: Affiliation, rhs: Affiliation) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.member == rhs.member
        && lhs.start == rhs.start
        && lhs.end == rhs.end
        && lhs.isCurrent == rhs.isCurrent
        && lhs.organization == rhs.organization
}

