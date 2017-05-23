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
    
    var order: Int64 { get }
    
    var event: Identifier { get }
}

// MARK: - Extensions

public extension Collection where Iterator.Element: PresentationMaterial {
    
    func ordered() -> [Iterator.Element] {
        
        return self.sorted { $0.0.order < $0.1.order }
    }
}
