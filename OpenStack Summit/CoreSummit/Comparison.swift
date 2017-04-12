//
//  Comparison.swift
//  Predicate
//
//  Created by Alsey Coleman Miller on 4/2/17.
//  Copyright © 2017 PureSwift. All rights reserved.
//

public struct Comparision {
    
    public var expression: (left: Expression, right: Expression)
    
    public var type: Operator
    
    public var modifier: Modifier?
    
    public var options: Set<Option>
    
    init(expression: (left: Expression, right: Expression),
         type: Operator = .equalTo,
         modifier: Modifier? = nil,
         options: Set<Option> = []) {
        
        self.expression = expression
        self.type = type
        self.modifier = modifier
        self.options = options
    }
}

// MARK: - Supporting Types

public extension Comparision {

    public enum Modifier: String {
        
        case all        = "ALL"
        case any        = "ANY"
    }
    
    public enum Option: String {
        
        /// A case-insensitive predicate.
        case caseInsensitive        = "c"
        
        /// A diacritic-insensitive predicate.
        case diacriticInsensitive   = "d"
        
        /// Indicates that the strings to be compared have been preprocessed.
        case normalized             = "n"
        
        /// Indicates that strings to be compared using `<`, `<=`, `=`, `=>`, `>`
        /// should be handled in a locale-aware fashion.
        case localeSensitive        = "l"
    }
    
    public enum Operator: String {
        
        case lessThan               = "<"
        case lessThanOrEqualTo      = "<="
        case greaterThan            = ">"
        case greaterThanOrEqualTo   = ">="
        case equalTo                = "="
        case notEqualTo             = "!="
        case matches                = "MATCHES"
        case like                   = "LIKE"
        case beginsWith             = "BEGINSWITH"
        case endsWith               = "ENDSWITH"
        case `in`                   = "IN"
        case contains               = "CONTAINS"
        case between                = "BETWEEN"
    }
}

// MARK: - Equatable

extension Comparision: Equatable { }

public func == (lhs: Comparision, rhs: Comparision) -> Bool {
    
    return lhs.expression.left == rhs.expression.left
        && lhs.expression.right == rhs.expression.right
        && lhs.type == rhs.type
        && lhs.modifier == rhs.modifier
        && lhs.options == rhs.options
}

// MARK: - CustomStringConvertible

extension Comparision: CustomStringConvertible {
    
    public var description: String {
        
        let modifier = self.modifier?.rawValue ?? ""
        
        let leftExpression = "\(self.expression.left)"
        
        let type = self.type.rawValue
        
        let options = self.options.isEmpty ? "" : "[" + self.options
            .sort({ $0.0.rawValue < $0.1.rawValue })
            .reduce("") { $0.0 + $0.1.rawValue }
            + "]"
        
        let rightExpression = "\(self.expression.right)"
        
        let components = [modifier, leftExpression, type + options, rightExpression]
        
        return components.reduce("") { $0.0 + "\($0.0.isEmpty ? "" : " ")" + $0.1 }
    }
}

// MARK: - Operators

public func < (lhs: Expression, rhs: Expression) -> Predicate {
    
    let comparision = Comparision(expression: (left: lhs, right: rhs),
                                  type: .lessThan)
    
    return .comparison(comparision)
}

public func <= (lhs: Expression, rhs: Expression) -> Predicate {
    
    let comparision = Comparision(expression: (left: lhs, right: rhs),
                                  type: .lessThanOrEqualTo)
    
    return .comparison(comparision)
}

public func > (lhs: Expression, rhs: Expression) -> Predicate {
    
    let comparision = Comparision(expression: (left: lhs, right: rhs),
                                  type: .greaterThan)
    
    return .comparison(comparision)
}

public func >= (lhs: Expression, rhs: Expression) -> Predicate {
    
    let comparision = Comparision(expression: (left: lhs, right: rhs),
                                  type: .greaterThanOrEqualTo)
    
    return .comparison(comparision)
}

public func == (lhs: Expression, rhs: Expression) -> Predicate {
    
    let comparision = Comparision(expression: (left: lhs, right: rhs),
                                  type: .equalTo)
    
    return .comparison(comparision)
}

public func != (lhs: Expression, rhs: Expression) -> Predicate {
    
    let comparision = Comparision(expression: (left: lhs, right: rhs),
                                  type: .notEqualTo)
    
    return .comparison(comparision)
}

// LHS keypath and RHS predicate value

public func < <T: PredicateValue>(lhs: String, rhs: T) -> Predicate {
    
    let comparision = Comparision(expression: (left: .keyPath(lhs), right: .value(rhs.predicateValue)),
                                  type: .lessThan)
    
    return .comparison(comparision)
}

public func <= <T: PredicateValue>(lhs: String, rhs: T) -> Predicate {
    
    let comparision = Comparision(expression: (left: .keyPath(lhs), right: .value(rhs.predicateValue)),
                                  type: .lessThanOrEqualTo)
    
    return .comparison(comparision)
}

public func > <T: PredicateValue>(lhs: String, rhs: T) -> Predicate {
    
    let comparision = Comparision(expression: (left: .keyPath(lhs), right: .value(rhs.predicateValue)),
                                  type: .greaterThan)
    
    return .comparison(comparision)
}

public func >= <T: PredicateValue>(lhs: String, rhs: T) -> Predicate {
    
    let comparision = Comparision(expression: (left: .keyPath(lhs), right: .value(rhs.predicateValue)),
                                  type: .greaterThanOrEqualTo)
    
    return .comparison(comparision)
}

public func == <T: PredicateValue>(lhs: String, rhs: T) -> Predicate {
    
    let comparision = Comparision(expression: (left: .keyPath(lhs), right: .value(rhs.predicateValue)),
                                  type: .equalTo)
    
    return .comparison(comparision)
}


public func != <T: PredicateValue>(lhs: String, rhs: T) -> Predicate {
    
    let comparision = Comparision(expression: (left: .keyPath(lhs), right: .value(rhs.predicateValue)),
                                  type: .notEqualTo)
    
    return .comparison(comparision)
}

// Extensions for KeyPath comparisions
public extension String {
    
    func compare(type: Comparision.Operator, _ rhs: Expression) -> Predicate {
        
        let comparision = Comparision(expression: (.keyPath(self), rhs), type: type)
        
        return .comparison(comparision)
    }
    
    func compare(type: Comparision.Operator, _ options: Set<Comparision.Option>, _ rhs: Expression) -> Predicate {
        
        let comparision = Comparision(expression: (.keyPath(self), rhs), type: type, options: options)
        
        return .comparison(comparision)
    }
    
    func compare(modifier: Comparision.Modifier, _ type: Comparision.Operator, _ options: Set<Comparision.Option>, _ rhs: Expression) -> Predicate {
        
        let comparision = Comparision(expression: (.keyPath(self), rhs), type: type, modifier: modifier, options: options)
        
        return .comparison(comparision)
    }
    
    func any <Value: PredicateValue> (in collection: [Value]) -> Predicate {
        
        let values = collection.map { $0.predicateValue }
        
        let rightExpression = Expression.value(.collection(values))
        
        let comparision = Comparision(expression: (.keyPath(self), rightExpression), type: .`in`, modifier: .any)
        
        return .comparison(comparision)
    }
    
    func all <Value: PredicateValue> (in collection: [Value]) -> Predicate {
        
        let values = collection.map { $0.predicateValue }
        
        let rightExpression = Expression.value(.collection(values))
        
        let comparision = Comparision(expression: (.keyPath(self), rightExpression), type: .`in`, modifier: .all)
        
        return .comparison(comparision)
    }
    
    func `in` <Value: PredicateValue> (collection: [Value], options: Set<Comparision.Option> = []) -> Predicate {
        
        let values = collection.map { $0.predicateValue }
        
        let rightExpression = Expression.value(.collection(values))
        
        let comparision = Comparision(expression: (.keyPath(self), rightExpression), type: .`in`, options: options)
        
        return .comparison(comparision)
    }
}
