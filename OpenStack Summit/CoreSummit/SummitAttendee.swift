//
//  SummitAttendee.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public struct SummitAttendee: Unique {
    
    public let identifier: Identifier
    
    public var firstName: String
    
    public var lastName: String
        
    public var pictureURL: String
        
    public var twitter: String?
    
    public var irc: String?
    
    public var biography: String?
    
    //public var location: String
    
    public var tickets: [TicketType]
    
    public var scheduledEvents: [Identifier]
    
    public var feedback: [AttendeeFeedback]
    
    //public var bookmarkedEvents: [SummitEvent]
    
    //public var friends: [Member]
}

// MARK: - Extensions

extension SummitAttendee: Person {
    
    public var title: String? { return nil }
}