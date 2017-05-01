//
//  PresentationSlide.swift
//  OpenStack Summit
//
//  Created by Gabriel Horacio Cutrini on 4/28/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

public struct PresentationSlide: PresentationMaterial, Equatable {
    
    public let identifier: Identifier
    
    public var name: String
    
    public var descriptionText: String?
    
    public var displayOnSite: Bool
    
    public var featured: Bool
    
    public var order: Int
    
    public var link: String
}

// MARK: - Equatable

public func == (lhs: PresentationSlide, rhs: PresentationSlide) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.name == rhs.name
        && lhs.descriptionText == rhs.descriptionText
        && lhs.displayOnSite == rhs.displayOnSite
        && lhs.featured == rhs.featured
        && lhs.order == rhs.order
        && lhs.link == rhs.link
}
