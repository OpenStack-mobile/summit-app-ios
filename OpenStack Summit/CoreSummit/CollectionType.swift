//
//  CollectionType.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public extension Collection {
    
    /// Attempt to reduce and convert the contents of the collection to another type.
    func reduce<T>(to type: T.Type) -> [T] {
        
        var newTypeArray = [T]()
        
        for element in self {
            
            guard let newType = element as? T
                else { continue }
            
            newTypeArray.append(newType)
        }
        
        return newTypeArray
    }
}
