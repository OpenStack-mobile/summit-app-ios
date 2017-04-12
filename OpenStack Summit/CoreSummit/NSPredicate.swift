//
//  NSPredicate.swift
//  Predicate
//
//  Created by Alsey Coleman Miller on 4/2/17.
//  Copyright © 2017 PureSwift. All rights reserved.
//

import Foundation

public extension NSPredicate {
    
    convenience init(_ predicate: Predicate) {
        
        fatalError()
    }
}

public extension Predicate {
    
    func toFoundation() -> NSPredicate {
        
        switch self {
        case let .compound(predicate): return predicate.toFoundation()
        case let .comparison(predicate): return predicate.toFoundation()
        case let .value(value): return NSPredicate(value: value)
        }
    }
}

public extension Compound {
    
    func toFoundation() -> NSCompoundPredicate {
        
        let subpredicates = self.subpredicates.map { $0.toFoundation() }
        
        return NSCompoundPredicate(type: type.toFoundation(), subpredicates: subpredicates)
    }
}

public extension Compound.Logical​Type {
    
    func toFoundation() -> NSCompoundPredicateType {
        switch self {
        case .and: return .AndPredicateType
        case .or: return .OrPredicateType
        case .not: return .NotPredicateType
        }
    }
}

public extension Comparision {
    
    func toFoundation() -> NSComparisonPredicate {
        
        var rawOptions: UInt = 0
        
        self.options.forEach { rawOptions = rawOptions | $0.toFoundation().rawValue }
        
        let options = NSComparisonPredicateOptions(rawValue: rawOptions)
        
        return NSComparisonPredicate(leftExpression: expression.left.toFoundation(),
                                     rightExpression: expression.right.toFoundation(),
                                     modifier: modifier?.toFoundation() ?? .DirectPredicateModifier,
                                     type: type.toFoundation(),
                                     options: options)
    }
}

public extension Comparision.Modifier {
    
    func toFoundation() -> NSComparisonPredicateModifier {
        
        switch self {
        case .all: return .AllPredicateModifier
        case .any: return .AnyPredicateModifier
        }
    }
}

public extension Comparision.Operator {
    
    func toFoundation() -> NSPredicateOperatorType {
        
        switch self {
        case .lessThan:             return .LessThanPredicateOperatorType
        case .lessThanOrEqualTo:    return .LessThanOrEqualToPredicateOperatorType
        case .greaterThan:          return .GreaterThanPredicateOperatorType
        case .greaterThanOrEqualTo: return .GreaterThanOrEqualToPredicateOperatorType
        case .equalTo:              return .EqualToPredicateOperatorType
        case .notEqualTo:           return .NotEqualToPredicateOperatorType
        case .matches:              return .MatchesPredicateOperatorType
        case .like:                 return .LikePredicateOperatorType
        case .beginsWith:           return .BeginsWithPredicateOperatorType
        case .endsWith:             return .EndsWithPredicateOperatorType
        case .`in`:                 return .InPredicateOperatorType
        case .contains:             return .ContainsPredicateOperatorType
        case .between:              return .BetweenPredicateOperatorType
        }
    }
}

public extension Comparision.Option {
    
    func toFoundation() -> NSComparisonPredicateOptions {
        
        /// `NSLocale​Sensitive​Predicate​Option` is not availible in Swift for some reason.
        /// Lack of Swift annotation it seems.
        
        switch self {
        case .caseInsensitive: return .CaseInsensitivePredicateOption
        case .diacriticInsensitive: return .DiacriticInsensitivePredicateOption
        case .normalized: return .NormalizedPredicateOption
        case .localeSensitive: return NSComparisonPredicateOptions(rawValue: 0x08)
        }
    }
}

public extension Expression {
    
    func toFoundation() -> NSExpression {
        
        switch self {
        case let .keyPath(keyPath): return NSExpression(forKeyPath: keyPath)
        case let .value(value): return NSExpression(forConstantValue: value.toFoundation())
        }
    }
}

public extension Value {
    
    func toFoundation() -> AnyObject? {
        
        switch self {
        case .null: return nil
        case let .string(value):    return value as NSString
        case let .data(value):      return value.toFoundation()
        case let .date(value):      return value.toFoundation()
        case let .bool(value):      return NSNumber(bool: value)
        case let .int16(value):     return NSNumber(short: value)
        case let .int32(value):     return NSNumber(int: value)
        case let .int64(value):     return NSNumber(longLong: value)
        case let .float(value):     return NSNumber(float: value)
        case let .double(value):    return NSNumber(double: value)
        case let .collection(value): return value.map({ $0.toFoundation() ?? NSNull() }) as NSArray
        }
    }
}
