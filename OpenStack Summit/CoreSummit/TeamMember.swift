//
//  TeamMember.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 12/26/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

public extension Team {
    
    public typealias Member = TeamMember
}

public struct TeamMember: Named {
    
    public let identifier: Identifier
    
    public var firstName: String
    
    public var lastName: String
    
    public var pictureURL: String
    
    public var twitter: String?
    
    public var irc: String?
    
    public var permission: Permission
}

// MARK: - Equatable

public func == (lhs: Team.Member, rhs: Team.Member) -> Bool {
    
    return lhs.identifier == rhs.identifier &&
        lhs.firstName == rhs.firstName &&
        lhs.lastName == rhs.lastName &&
        lhs.pictureURL == rhs.pictureURL &&
        lhs.twitter == rhs.twitter &&
        lhs.irc == rhs.irc &&
        lhs.permission == rhs.permission
}

// MARK: - Person

extension Team.Member: Person {
    
    public var title: String? { return nil }
    
    public var biography: String? { return nil }
}

// MARK: - Supporting Types

public extension Team.Member {
    
    public enum Permission: String {
        
        case admin
        case read
        case write
    }
}
