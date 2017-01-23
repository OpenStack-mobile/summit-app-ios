//
//  SummitAttendee.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public struct Attendee: Unique {
    
    public let identifier: Identifier
    
    public var firstName: String
    
    public var lastName: String
        
    public var pictureURL: String
        
    public var twitter: String?
    
    public var irc: String?
    
    public var biography: String?
    
    public var tickets: Set<TicketType>
    
    public var scheduledEvents: Set<Identifier>
    
    public var feedback: Set<AttendeeFeedback>
}

// MARK: - Extensions

extension Attendee: Person {
    
    public var title: String? { return nil }
}

// MARK: - Equatable

public func == (lhs: Attendee, rhs: Attendee) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.firstName == rhs.firstName
        && lhs.lastName == rhs.lastName
        && lhs.pictureURL == rhs.pictureURL
        && lhs.twitter == rhs.twitter
        && lhs.irc == rhs.irc
        && lhs.biography == rhs.biography
        && lhs.tickets == rhs.tickets
        && lhs.scheduledEvents == rhs.scheduledEvents
        && lhs.feedback == rhs.feedback
}
