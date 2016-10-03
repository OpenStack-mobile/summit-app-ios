//
//  FeedbackOwner.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 10/3/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public extension Feedback {
    
    public typealias Owner = FeedbackOwner
}

public struct FeedbackOwner: Unique {
    
    public let identifier: Identifier
    
    public let attendee: Identifier
    
    public let firstName: String
    
    public let lastName: String
}