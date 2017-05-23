//
//  JSONExtensions.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 5/12/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import JSON
import struct Foundation.URL

// MARK: - Extensions

public extension JSONDecodable {
    
    /// Decodes from an array of JSON values and skips values that cannot be decoded.
    static func forceDecode(json array: JSON.Array) -> [Self] {
        
        var jsonDecodables: ContiguousArray<Self> = ContiguousArray()
        
        jsonDecodables.reserveCapacity(array.count)
        
        for jsonValue in array {
            
            guard let jsonDecodable = self.init(json: jsonValue) else { continue }
            
            jsonDecodables.append(jsonDecodable)
        }
        
        return Array(jsonDecodables)
    }
}

// MARK: - URL JSON Support

extension URL: JSONDecodable {
    
    public init?(json: JSON.Value) {
        
        guard let urlString = json.stringValue
            else { return nil }
        
        self.init(string: urlString)
    }
}

extension URL: JSONEncodable {
    
    public func toJSON() -> JSON.Value {
        
        return .string(absoluteString)
    }
}

public extension JSON.Value {
    
    public var urlValue: URL? {
        
        return URL(json: self)
    }
}
