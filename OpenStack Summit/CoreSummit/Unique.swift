//
//  Unique.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 5/31/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

/// A data type that can be uniquely identified.
public protocol Unique: Equatable, Hashable, Comparable {
    
    var identifier: Identifier { get }
}

public typealias Identifier = Int

// MARK: - Hashable

public extension Unique {
    
    var hashValue: Int {
        
        return identifier
    }
}

// MARK: - Comparable

public func < <T: Unique> (lhs: T, rhs: T) -> Bool {
    
    return lhs.identifier < rhs.identifier
}

// MARK: - Extensions

public extension CollectionType where Generator.Element: Unique {
    
    var identifiers: [Identifier] {
        
        return self.map { $0.identifier }
    }
    
    @inline(__always)
    func with(identifier: Identifier) -> Self.Generator.Element? {
        
        return firstMatching { $0.identifier == identifier }
    }
}