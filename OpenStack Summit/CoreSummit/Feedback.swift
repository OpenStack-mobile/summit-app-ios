//
//  Feedback.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import struct SwiftFoundation.Date

public struct Feedback<Owner: FeedbackOwner>: Unique {
    
    public let identifier: Identifier
    
    public var rate: Int
    
    public var review: String
    
    public var date: Date
    
    public var event: Identifier
    
    public var owner: Owner
}

public typealias MemberFeedback = Feedback<FeedbackMemberOwner>
public typealias Review = Feedback<FeedbackNamedOwner>

// MARK: - Feedback Owner

public protocol FeedbackOwner: Unique {
    
    /// The member identifier of the owner.
    var identifier: Identifier { get }
    
    /// The attendee identifier of the owner.
    var attendee: Identifier { get }
}

public struct FeedbackNamedOwner: FeedbackOwner {
    
    public let identifier: Identifier
    
    public let attendee: Identifier
    
    public let firstName: String
    
    public let lastName: String
}

public struct FeedbackMemberOwner: FeedbackOwner {
    
    public let identifier: Identifier
    
    public let attendee: Identifier
}
