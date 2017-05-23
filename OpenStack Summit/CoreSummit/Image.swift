//
//  Image.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import struct Foundation.URL

public struct Image: Unique {
    
    public let identifier: Identifier
    
    public var url: URL
}

public func == (lhs: Image, rhs: Image) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.url == rhs.url
}
