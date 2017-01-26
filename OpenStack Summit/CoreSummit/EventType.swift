//
//  EventType.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public struct EventType: Named {
    
    public let identifier: Identifier
    
    public var name: String
    
    public var color: String
    
    public var blackOutTimes: Bool
}

// MARK: - Equatable

public func == (lhs: EventType, rhs: EventType) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.name == rhs.name
        && lhs.color == rhs.color
        && lhs.blackOutTimes == rhs.blackOutTimes
}
