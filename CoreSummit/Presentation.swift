//
//  Presentation.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/3/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public struct Presentation: Unique {
    
    public let identifier: Identifier
    
    public var level: String
    
    public var track: Identifier
    
    public var moderator: Identifier?
    
    public var speakers: [Identifier]
}