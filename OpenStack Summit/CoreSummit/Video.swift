//
//  Video.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 8/16/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public struct Video: Named, Equatable {
    
    public let identifier: Identifier
    
    public var name: String
    
    public var descriptionText: String?
    
    public var displayOnSite: Bool
    
    public var featured: Bool
        
    public var youtube: String
}

// MARK: - Equatable

public func == (lhs: Video, rhs: Video) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.name == rhs.name
        && lhs.descriptionText == rhs.descriptionText
        && lhs.displayOnSite == rhs.displayOnSite
        && lhs.featured == rhs.featured
        && lhs.youtube == rhs.youtube
}