//
//  SummitAttendee.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public struct Attendee: Unique {
    
    public let identifier: Identifier
    
    public var member: Identifier
    
    public var schedule: Set<Identifier>
    
    public var tickets: Set<Identifier>
}

// MARK: - Equatable

public func == (lhs: Attendee, rhs: Attendee) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.member == rhs.member
        && lhs.schedule == rhs.schedule
        && lhs.tickets == rhs.tickets
}
