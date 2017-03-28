//
//  Feedback.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import struct SwiftFoundation.Date

public protocol FeedbackProtocol: Unique {
    
    var identifier: Identifier { get }
    
    var rate: Int { get }
    
    var review: String { get }
    
    var date: Date { get }
    
    var event: Identifier { get }
}

public struct Feedback: FeedbackProtocol {
    
    public let identifier: Identifier
    
    public let rate: Int
    
    public let review: String
    
    public let date: Date
    
    public let event: Identifier
    
    public let member: Member
}

public func == (lhs: Feedback, rhs: Feedback) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.rate == rhs.rate
        && lhs.review == rhs.review
        && lhs.date == rhs.date
        && lhs.event == lhs.event
        && lhs.member == lhs.member
}
