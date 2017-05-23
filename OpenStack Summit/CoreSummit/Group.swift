//
//  Group.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 1/23/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation

public struct Group: Unique {
    
    public let identifier: Identifier
    
    public var title: String
    
    public var descriptionText: String?
    
    public var code: String
}

// MARK: - Equatable

public func == (lhs: Group, rhs: Group) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.title == rhs.title
        && lhs.descriptionText == rhs.descriptionText
        && lhs.code == rhs.code
}
