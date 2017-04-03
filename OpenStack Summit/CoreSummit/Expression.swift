//
//  Expression.swift
//  Predicate
//
//  Created by Alsey Coleman Miller on 4/2/17.
//  Copyright © 2017 PureSwift. All rights reserved.
//

/// Used to represent expressions in a predicate.
public enum Expression {
    
    /// Expression that represents a given constant value.
    case value(Value)
    
    /// Expression that invokes `value​For​Key​Path:​` with a given key path.
    case keyPath(String)
}

// MARK: - Equatable

extension Expression: Equatable { }

public func == (lhs: Expression, rhs: Expression) -> Bool {
    
    switch (lhs, rhs) {
    case let (.keyPath(lhsValue), .keyPath(rhsValue)): return lhsValue == rhsValue
    case let (.value(lhsValue), .value(rhsValue)): return lhsValue == rhsValue
    default: return false
    }
}

// MARK: - CustomStringConvertible

extension Expression: CustomStringConvertible {
    
    public var description: String {
        
        switch self {
        case let .value(value):    return "\(value)"
        case let .keyPath(value):  return "\(value)"
        }
    }
}

// MARK: - Extensions

public extension Expression {
    
    func compare(type: Comparision.Operator, _ rhs: Expression) -> Predicate {
        
        let comparision = Comparision(expression: (self, rhs), type: type)
        
        return .comparison(comparision)
    }
    
    func compare(type: Comparision.Operator, _ options: Set<Comparision.Option>, _ rhs: Expression) -> Predicate {
        
        let comparision = Comparision(expression: (self, rhs), type: type, options: options)
        
        return .comparison(comparision)
    }
    
    func compare(modifier: Comparision.Modifier, _ type: Comparision.Operator, _ options: Set<Comparision.Option>, _ rhs: Expression) -> Predicate {
        
        let comparision = Comparision(expression: (self, rhs), type: type, modifier: modifier, options: options)
        
        return .comparison(comparision)
    }
}

