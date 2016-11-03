//
//  SummitType.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public struct SummitType: Named, Equatable {
    
    public let identifier: Identifier
    
    public var name: String
    
    public var color: String
}

// MARK: - Equatable

public func == (lhs: SummitType, rhs: SummitType) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.name == rhs.name
        && lhs.color == rhs.color
}