//
//  Link.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 5/5/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import struct Foundation.URL

public struct Link: PresentationMaterial {
    
    public let identifier: Identifier
    
    public var name: String
    
    public var descriptionText: String?
    
    public var displayOnSite: Bool
    
    public var featured: Bool
    
    public var order: Int64
    
    public var link: URL
    
    public var event: Identifier
}

// MARK: - Equatable

public func == (lhs: Link, rhs: Link) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.name == rhs.name
        && lhs.descriptionText == rhs.descriptionText
        && lhs.displayOnSite == rhs.displayOnSite
        && lhs.featured == rhs.featured
        && lhs.order == rhs.order
        && lhs.link == rhs.link
        && lhs.event == rhs.event
}
