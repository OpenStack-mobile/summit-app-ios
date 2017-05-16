//
//  Video.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 8/16/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import struct Foundation.Date

public struct Video: PresentationMaterial {
    
    public let identifier: Identifier
    
    public var name: String
    
    public var descriptionText: String?
    
    public var displayOnSite: Bool
    
    public var featured: Bool
    
    public var highlighted: Bool
        
    public var youtube: String
    
    public var dataUploaded: Date
    
    public var order: Int64
    
    public var views: Int64
    
    public var event: Identifier
}

// MARK: - Equatable

public func == (lhs: Video, rhs: Video) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.name == rhs.name
        && lhs.descriptionText == rhs.descriptionText
        && lhs.displayOnSite == rhs.displayOnSite
        && lhs.featured == rhs.featured
        && lhs.youtube == rhs.youtube
        && lhs.highlighted == rhs.highlighted
        && lhs.dataUploaded == rhs.dataUploaded
        && lhs.order == rhs.order
        && lhs.views == rhs.views
        && lhs.event == rhs.event
}
