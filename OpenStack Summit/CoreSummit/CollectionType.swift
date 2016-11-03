//
//  CollectionType.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 9/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public extension CollectionType {
    
    @inline(__always)
    func firstMatching(@noescape predicate: (Self.Generator.Element) throws -> Bool) rethrows -> Self.Generator.Element? {
        
        guard let index = try self.indexOf(predicate)
            else { return nil }
        
        return self[index]
    }
}