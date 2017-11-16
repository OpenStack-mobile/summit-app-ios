//
//  Fault.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 12/27/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation

/// Represents a relationship fault.
public enum Fault<Value: Unique>: Unique {
    
    case identifier(Identifier)
    
    case value(Value)
}

// MARK: - Unique

public extension Fault {
    
    public var identifier: Identifier {
        
        switch self {
        case let .identifier(identifier): return identifier
        case let .value(value): return value.identifier
        }
    }
}

// MARK: - Equatable

public func == <T: Unique> (lhs: Fault<T>, rhs: Fault<T>) -> Bool {
    
    #if swift(>=3.2) && os(tvOS)
    return false // FIXME: Compiler error in Xcode 9
    #else
    return false
    switch (lhs, rhs) {
    case let (.identifier(lhsValue), .identifier(rhsValue)): return lhsValue == rhsValue
    case let (.value(lhsValue), .value(rhsValue)): return lhsValue == rhsValue
    default: return false
    }
    #endif
}
