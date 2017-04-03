//
//  Value.swift
//  Predicate
//
//  Created by Alsey Coleman Miller on 4/2/17.
//  Copyright © 2017 PureSwift. All rights reserved.
//

import SwiftFoundation

/// Constant value used in predicate expressions.
public enum Value {
    
    case null
    case string(String)
    case data(Data)
    case date(Date)
    case bool(Bool)
    case int16(Int16)
    case int32(Int32)
    case int64(Int64)
    case float(Float)
    case double(Double)
    case collection([Value])
}

// MARK: - Equatable

extension Value: Equatable { }

public func == (lhs: Value, rhs: Value) -> Bool {
    
    switch (lhs, rhs) {
    case (.null, .null):                                return true
    case let (.string(lhsValue), .string(rhsValue)):    return lhsValue == rhsValue
    case let (.data(lhsValue), .data(rhsValue)):        return lhsValue == rhsValue
    case let (.date(lhsValue), .date(rhsValue)):        return lhsValue == rhsValue
    case let (.bool(lhsValue), .bool(rhsValue)):        return lhsValue == rhsValue
    case let (.int16(lhsValue), .int16(rhsValue)):      return lhsValue == rhsValue
    case let (.int32(lhsValue), .int32(rhsValue)):      return lhsValue == rhsValue
    case let (.int64(lhsValue), .int64(rhsValue)):      return lhsValue == rhsValue
    case let (.float(lhsValue), .float(rhsValue)):      return lhsValue == rhsValue
    case let (.double(lhsValue), .double(rhsValue)):    return lhsValue == rhsValue
    case let (.collection(lhsValue), .collection(rhsValue)): return lhsValue == rhsValue
    default: return false
    }
}

// MARK: - CustomStringConvertible

extension Value: CustomStringConvertible {
    
    public var description: String {
        
        switch self {
        case .null:                 return "NULL"
        case let .string(value):    return "\"\(value)\""
        case let .data(value):      return "\(value)"
        case let .date(value):      return "\(value)"
        case let .bool(value):      return "\(value)"
        case let .int16(value):     return "\(value)"
        case let .int32(value):     return "\(value)"
        case let .int64(value):     return "\(value)"
        case let .float(value):     return "\(value)"
        case let .double(value):    return "\(value)"
            
        case let .collection(values):
            
            var text = "{"
            
            for (index, value) in values.enumerate() {
                
                text += value.description
                
                if index != values.count - 1 {
                    
                    text += ", "
                }
            }
            
            text += "}"
            
            return text
        }
    }
}

// MARK: - Supporting Types

public protocol PredicateValue {
    
    var predicateValue: Value { get }
}

extension String: PredicateValue {
    public var predicateValue: Value { return .string(self) }
}

extension Data: PredicateValue {
    public var predicateValue: Value { return .data(self) }
}

extension Date: PredicateValue {
    public var predicateValue: Value { return .date(self) }
}

extension Bool: PredicateValue {
    public var predicateValue: Value { return .bool(self) }
}

extension Int16: PredicateValue {
    public var predicateValue: Value { return .int16(self) }
}

extension Int32: PredicateValue {
    public var predicateValue: Value { return .int32(self) }
}

extension Int64: PredicateValue {
    public var predicateValue: Value { return .int64(self) }
}

extension Int: PredicateValue {
    public var predicateValue: Value { return .int64(Int64(self)) }
}

extension Float: PredicateValue {
    public var predicateValue: Value { return .float(self) }
}

extension Double: PredicateValue {
    public var predicateValue: Value { return .double(self) }
}

extension Array where Element: PredicateValue {
    public var predicateValue: Value { return .collection(self.map({ $0.predicateValue })) }
}
