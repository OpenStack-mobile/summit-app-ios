//
//  Level.swift
//  OpenStack Summit
//
//  Created by Gabriel Horacio Cutrini on 4/18/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

public enum Level: String, Comparable {
    
    case Beginner
    case Intermediate
    case Advanced
    case NotApplicable = "N/A"
    
    public var order: Int {
        
        switch self {
        case .Beginner: return 0
        case .Intermediate: return 1
        case .Advanced: return 2
        case .NotApplicable: return 3
        }
    }
}

// MARK: - Comparable

public func == (lhs: Level, rhs: Level) -> Bool {
    
    return lhs.order == rhs.order
}

public func < (lhs: Level, rhs: Level) -> Bool {
    
    return lhs.order < rhs.order
}
