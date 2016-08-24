//
//  Presentation.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/3/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public struct Presentation: Unique {
    
    public let identifier: Identifier
    
    public var level: Level?
    
    public var track: Identifier?
    
    public var moderator: Identifier?
    
    public var speakers: [Identifier]
}

public extension Presentation {
    
    public enum Level: String {
        
        case Beginner
        case Intermediate
        case Advanced
        case NotApplicable = "N/A"
    }
}