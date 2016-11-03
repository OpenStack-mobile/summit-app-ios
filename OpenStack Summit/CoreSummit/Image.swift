//
//  Image.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public struct Image: Unique, Equatable {
    
    public let identifier: Identifier
    
    public var url: String
}

public func == (lhs: Image, rhs: Image) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.url == rhs.url
}
