//
//  Predicate.swift
//  Predicate
//
//  Created by Alsey Coleman Miller on 4/2/17.
//  Copyright © 2017 PureSwift. All rights reserved.
//

/// You use predicates to represent logical conditions, used for describing objects in persistent stores and in-memory filtering of objects.
public enum Predicate {
    
    case comparison(Comparision)
    case compound(Compound)
    case value(Bool)
}

// MARK: - Equatable

extension Predicate: Equatable { }

public func == (lhs: Predicate, rhs: Predicate) -> Bool {
    
    switch (lhs, rhs) {
    case let (.comparison(lhsValue), .comparison(rhsValue)): return lhsValue == rhsValue
    case let (.compound(lhsValue), .compound(rhsValue)): return lhsValue == rhsValue
    case let (.value(lhsValue), .value(rhsValue)): return lhsValue == rhsValue
    default: return false
    }
}

// MARK: - CustomStringConvertible

extension Predicate: CustomStringConvertible {
    
    public var description: String {
        
        switch self {
        case let .comparison(value):    return "\(value)"
        case let .compound(value):      return "\(value)"
        case let .value(value):         return "\(value)"
        }
    }
}

// MARK: - Evaluate

/// Protocol for types that can be evaluated with a predicate.
public protocol PredicateEvaluatable {
    
    func evaluate(with predicate: Predicate) throws -> Bool
}

extension SequenceType where Generator.Element: PredicateEvaluatable {
    
    func evaluate(with predicate: Predicate) throws -> Bool {
        
        for element in self {
            
            guard try element.evaluate(with: predicate)
                else { return false }
        }
        
        return true
    }
}

// MARK: - Convert

/// Value can be converted to a predicate, typically an expression constant value.
public protocol PredicateConvertible {
    
    func toPredicate() -> Predicate
}
