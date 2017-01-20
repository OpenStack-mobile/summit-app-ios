//
//  Fault.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 12/27/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

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
    
    switch (lhs, rhs) {
    case let (.identifier(lhsValue), .identifier(rhsValue)): return lhsValue == rhsValue
    case let (.value(lhsValue), .value(rhsValue)): return lhsValue == rhsValue
    default: return false
    }
}


// MARK: - Generic Faults

public protocol FaultConvertible: Unique, CoreDataDecodable {
    
    associatedtype Value: Unique, CoreDataDecodable
    
    init?(fault: Fault<Value>)
    
    func toFault() -> Fault<Value>
}

public struct Expanded<Value where Value: Unique, Value: CoreDataDecodable>: FaultConvertible {
    
    public var identifier: Identifier { return value.identifier }
    
    public var value: Value
    
    public init(managedObject: Value.ManagedObject) {
        
        self.value = Value(managedObject)
    }
    
    public init?(fault: Fault<Value>) {
        
        switch fault {
        case .identifier: return nil
        case let .value(value): self.value = value
        }
    }
    
    public func toFault() -> Fault<Value> {
        
        return .value(value)
    }
}

public func == <Value where Value: Unique, Value: CoreDataDecodable> (lhs: Expanded<Value>, rhs: Expanded<Value>) -> Bool {
    
    return lhs.value == rhs.value
}

public struct Reference<Value where Value: Unique, Value: CoreDataDecodable>: FaultConvertible {
    
    public var identifier: Identifier
    
    public init(managedObject: ManagedObject) {
        
        self.identifier = managedObject.identifier
    }
    
    public init?(fault: Fault<Value>) {
        
        self.identifier = fault.identifier
    }
    
    public func toFault() -> Fault<Value> {
        
        return .identifier(identifier)
    }
}

public func == <Value where Value: Unique, Value: CoreDataDecodable> (lhs: Reference<Value>, rhs: Reference<Value>) -> Bool {
    
    return lhs.identifier == rhs.identifier
}
