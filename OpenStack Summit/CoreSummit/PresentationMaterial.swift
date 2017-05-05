//
//  PresentationMaterial.swift
//  OpenStack Summit
//
//  Created by Gabriel Horacio Cutrini on 4/28/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

public protocol PresentationMaterial: Named {
        
    var descriptionText: String? { get }
    
    var displayOnSite: Bool { get }
    
    var featured: Bool { get }
    
    var order: Int { get }
    
    var event: Identifier { get }
}

// MARK: - Extensions

public extension CollectionType where Generator.Element: PresentationMaterial {
    
    func ordered() -> [Generator.Element] {
        
        return self.sort { $0.0.order < $0.1.order }
    }
}
