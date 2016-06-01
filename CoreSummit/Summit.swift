//
//  Summit.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 5/31/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import struct SwiftFoundation.Date

public struct Summit: Named {
    
    public let identifier: Identifier
    
    public var name: String
    
    public var timeZone: TimeZone
    
    public var start: Date
    
    public var end: Date
    
    public var active: Bool
    
    public var startShowingVenues: Date?
    
    /// Realm only value, not returned from JSON.
    public var initialDataLoad: Date?
    
    public var logo: String?
    
    
}


