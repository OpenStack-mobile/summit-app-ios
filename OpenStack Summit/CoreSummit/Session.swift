//
//  Session.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 7/31/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

/// Provides the storage for session values
public protocol SessionStorage {
    
    var member: SessionMember?  { get set }
}

/// The type of member for the current session. 
public enum SessionMember {
    
    case attendee(Identifier)
    case nonConfirmedAttendee
}