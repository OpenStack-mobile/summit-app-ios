//
//  Presentation.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/3/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public struct Presentation: Unique, Equatable {
    
    public let identifier: Identifier
    
    public var level: Level?
    
    public var moderator: Identifier?
    
    public var speakers: Set<Identifier>
}

// MARK: - Equatable

public func == (lhs: Presentation, rhs: Presentation) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.level == rhs.level
        && lhs.moderator == rhs.moderator
        && lhs.speakers == rhs.speakers
}
