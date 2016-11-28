//
//  Track.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public struct Track: Named, Equatable {
    
    public let identifier: Identifier
    
    public var name: String
        
    public var groups: Set<Identifier>
}

// MARK: - Equatable

public func == (lhs: Track, rhs: Track) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.name == rhs.name
        && lhs.groups == rhs.groups
}