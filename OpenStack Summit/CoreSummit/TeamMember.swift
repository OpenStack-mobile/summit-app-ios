//
//  TeamMember.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 12/26/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

public struct TeamMember: Named {
    
    public let identifier: Identifier
    
    public var firstName: String
    
    public var lastName: String
    
    public var pictureURL: String
    
    public var twitter: String?
    
    public var irc: String?
}

// MARK: - Equatable

public func == (lhs: TeamMember, rhs: TeamMember) -> Bool {
    
    return lhs.identifier == rhs.identifier &&
        lhs.firstName == rhs.firstName &&
        lhs.lastName == rhs.lastName &&
        lhs.pictureURL == rhs.pictureURL &&
        lhs.twitter == rhs.twitter &&
        lhs.irc == rhs.irc
}

// MARK: - Person

extension TeamMember: Person {
    
    public var title: String? { return nil }
    
    public var biography: String? { return nil }
}
