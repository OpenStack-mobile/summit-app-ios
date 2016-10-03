//
//  Feedback.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import struct SwiftFoundation.Date

public struct Feedback: Unique {
    
    public let identifier: Identifier
    
    public var rate: Int
    
    public var review: String
    
    public var date: Date
    
    public var event: Identifier
    
    public var owner: Owner
}
