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
        
        public let attendee: Identifier
        
        public let firstName: String
        
        public let lastName: String
    }
}

public struct AttendeeFeedback: Feedback {
    
    public let identifier: Identifier
    
    public var rate: Int
    
    public var review: String
    
    public var date: Date
    
    public var event: Identifier
    
    public let member: Identifier
    
    public let attendee: Identifier
}
