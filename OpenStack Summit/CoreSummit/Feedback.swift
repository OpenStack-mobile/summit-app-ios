//
//  Feedback.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import struct SwiftFoundation.Date

public protocol Feedback: Unique {
    
    var identifier: Identifier { get }
    
    var rate: Int { get }
    
    var review: String { get }
    
    var date: Date { get }
    
    var event: Identifier { get }
}

public struct Review: Feedback {
    
    public let identifier: Identifier
    
    public var rate: Int
    
    public var review: String
    
    public var date: Date
    
    public var event: Identifier
    
    public var owner: Owner
    
    public struct Owner {
        
        public let member: Identifier
        
        public let attendee: Identifier?
        
        public let firstName: String
        
        public let lastName: String
    }
}

public func == (lhs: Review, rhs: Review) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.rate == rhs.rate
        && lhs.review == rhs.review
        && lhs.date == rhs.date
        && lhs.event == lhs.event
        && lhs.owner == lhs.owner
}

public func == (lhs: Review.Owner, rhs: Review.Owner) -> Bool {
    
    return lhs.member == rhs.member
        && lhs.attendee == rhs.attendee
        && lhs.firstName == rhs.firstName
        && lhs.lastName == rhs.lastName
}

public struct MemberFeedback: Feedback {
    
    public let identifier: Identifier
    
    public var rate: Int
    
    public var review: String
    
    public var date: Date
    
    public var event: Identifier
    
    public let member: Identifier
}

public func == (lhs: MemberFeedback, rhs: MemberFeedback) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.rate == rhs.rate
        && lhs.review == rhs.review
        && lhs.date == rhs.date
        && lhs.event == lhs.event
        && lhs.member == lhs.member
}
