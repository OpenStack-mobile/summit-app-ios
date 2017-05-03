//
//  PresentationMaterial.swift
//  OpenStack Summit
//
//  Created by Gabriel Horacio Cutrini on 4/28/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

public protocol PresentationMaterial: Named {
    
    var name: String { get }
    
    var descriptionText: String? { get }
    
    var displayOnSite: Bool { get }
    
    var featured: Bool { get }
}
