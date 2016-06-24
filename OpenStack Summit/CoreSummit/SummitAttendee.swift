//
//  SummitAttendee.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public struct SummitAttendee: Person {
    
    public let identifier: Identifier
    
    public var firstName: String
    
    public var lastName: String
    
    public var title: String
    
    public var pictureURL: String
    
    public var email: String
    
    public var twitter: String?
    
    public var irc: String?
    
    public var biography: String
    
    //public var location: String
    
    public var tickets: [TicketType]
    
    public var scheduledEvents: [SummitEvent]
    
    public var feedback: [Feedback]
    
    //public var bookmarkedEvents: [SummitEvent]
    
    //public var friends: [Member]
}

// MARK: - Extensions

public extension Person {
    
    var attendee: Bool { return self is SummitAttendee }
}