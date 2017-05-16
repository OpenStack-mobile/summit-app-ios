//
//  NonConfirmedSummitAttendee.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public struct NonConfirmedAttendee: Named {
    
    public let identifier: Identifier
    
    public var firstName: String
    
    public var lastName: String
}

public extension NonConfirmedAttendee {
    
    var name: String { return firstName + " " + lastName }
}

// MARK: - Equatable

public func == (lhs: NonConfirmedAttendee, rhs: NonConfirmedAttendee) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.firstName == rhs.firstName
        && lhs.lastName == rhs.lastName
}
