//
//  Tag.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public struct Tag: Named {
    
    public let identifier: Identifier
    
    public var name: String
}

// MARK: - Equatable

public func == (lhs: Tag, rhs: Tag) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.name == rhs.name
}
