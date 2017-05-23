//
//  RawRepresentable.swift
//  SwiftFoundation
//
//  Created by Alsey Coleman Miller on 7/4/15.
//  Copyright © 2015 PureSwift. All rights reserved.
//

// MARK: - Convert Array of RawRepresentables

internal extension RawRepresentable {
    
    /// Creates a collection of ```RawRepresentable``` from a collection of raw values. 
    /// åReturns ```nil``` if an element in the array had an invalid raw value.
    static func from(rawValues: [RawValue]) -> [Self]? {
        
        var representables = [Self]()
        
        for element in rawValues {
            
            guard let rawRepresentable = self.init(rawValue: element) else { return nil }
            
            representables.append(rawRepresentable)
        }
        
        return representables
    }
}

internal extension Sequence where Self.Iterator.Element: RawRepresentable {

    /// Convertes a sequence of `RawRepresentable` to its raw values.
    var rawValues: [Self.Iterator.Element.RawValue] {
        
        return self.map { $0.rawValue }
    }

}

