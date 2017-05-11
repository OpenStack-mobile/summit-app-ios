//
//  Level.swift
//  OpenStack Summit
//
//  Created by Gabriel Horacio Cutrini on 4/18/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

public enum Level: String, Comparable {
    
    case beginner = "Beginner"
    case intermediate = "Intermediate"
    case advanced = "Advanced"
    case notApplicable = "N/A"
    
    public var order: Int {
        
        switch self {
        case .beginner:         return 0
        case .intermediate:     return 1
        case .advanced:         return 2
        case .notApplicable:    return 3
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
