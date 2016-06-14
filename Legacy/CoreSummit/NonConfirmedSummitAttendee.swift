//
//  NonConfirmedSummitAttendee.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public struct NonConfirmedSummitAttendee: Named {
    
    public let identifier: Identifier
    
    public var firstName: String
    
    public var lastName: String
}

public extension NonConfirmedSummitAttendee {
    
    var name: String { return firstName + " " + lastName }
}