//
//  SummitEvent.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import struct SwiftFoundation.Date

public struct SummitEvent: Named {
    
    public let identifier: Identifier
    
    public var name: String
    
    public var descriptionText: String
    
    public var start: Date
    
    public var end: Date
    
    public var allowFeedback: Bool
    
    public var averageFeedback: Double
}