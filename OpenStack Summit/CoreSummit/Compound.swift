//
//  Compound.swift
//  Predicate
//
//  Created by Alsey Coleman Miller on 4/2/17.
//  Copyright © 2017 PureSwift. All rights reserved.
//

/// Predicate type used to represent logical “gate” operations (AND/OR/NOT) and comparison operations.
public indirect enum Compound {
    
    case and([Predicate])
    case or([Predicate])
    case not(Predicate)
}

// MARK: - Accessors

public extension Compound {
    
    public var type: Logical​Type {
        
        switch self {
        case .and:  return .and
        case .or:   return .or
        case .not:  return .not
        }
    }
    
    public var subpredicates: [Predicate] {
        
        switch self {
        case let .and(subpredicates):   return subpredicates
        case let .or(subpredicates):    return subpredicates
        case let .not(subpredicate):    return [subpredicate]
        }
    }
}

// MARK: - Supporting Types

public extension Compound {
    
    /// Possible Compund Predicate types.
    public enum Logical​Type: String {
        
        /// A logical NOT predicate.
        case not = "NOT"
        
        /// A logical AND predicate.
        case and = "AND"
        
        /// A logical OR predicate.
        case or = "OR"
    }
}

// MARK: - Equatable

extension Compound: Equatable { }

public func == (lhs: Compound, rhs: Compound) -> Bool {
    
    switch (lhs, rhs) {
    case let (.and(lhsValue), .and(rhsValue)): return lhsValue == rhsValue
    case let (.or(lhsValue), .or(rhsValue)): return lhsValue == rhsValue
    case let (.not(lhsValue), .not(rhsValue)): return lhsValue == rhsValue
    default: return false
    }
}

// MARK: - CustomStringConvertible

extension Compound: CustomStringConvertible {
    
    public var description: String {
        
        guard subpredicates.isEmpty == false else {
            
            return "(Empty \(type) predicate)"
        }
        
        var text = ""
        
        for (index, predicate) in subpredicates.enumerate() {
            
            let showType: Bool
            
            if index == 0 {
                
                showType = subpredicates.count == 1
                
            } else {
                
                showType = true
                
                text += " "
            }
            
            if showType {
                
                text += type.rawValue + " "
            }
            
            let includeBrackets: Bool
            
            switch predicate {
            case .compound: includeBrackets = true
            case .comparison, .value: includeBrackets = false
            }
            
            text += includeBrackets ? "(" + predicate.description + ")" : predicate.description
        }
        
        return text
    }
}

// MARK: - Predicate Operators

// Not `&&` becuase of Swift 2 compiler limitations
// http://stackoverflow.com/questions/28816048/swift-expressions-was-too-complex-to-be-solved-in-reasonable-time

infix operator &&& {
    associativity left
    precedence 120
}

infix operator ||| {
    associativity left
    precedence 110
}

public func &&& (lhs: Predicate, rhs: Predicate) -> Predicate {
    
    return .compound(.and([lhs, rhs]))
}

public func &&& (lhs: Predicate, rhs: [Predicate]) -> Predicate {
    
    return .compound(.and([lhs] + rhs))
}

public func ||| (lhs: Predicate, rhs: Predicate) -> Predicate {
    
    return .compound(.or([lhs, rhs]))
}

public func ||| (lhs: Predicate, rhs: [Predicate]) -> Predicate {
    
    return .compound(.or([lhs] + rhs))
}

public prefix func ! (rhs: Predicate) -> Predicate {
    
    return .compound(.not(rhs))
}
