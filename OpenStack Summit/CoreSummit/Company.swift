//
//  Company.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public struct Company: Named, Equatable {
    
    public let identifier: Identifier
    
    public var name: String
}

// MARK: - Equatable

public func == (lhs: Company, rhs: Company) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.name == rhs.name
}
