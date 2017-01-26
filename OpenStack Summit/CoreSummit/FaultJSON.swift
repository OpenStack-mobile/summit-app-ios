//
//  FaultJSON.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 12/27/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

public extension Fault where Value: JSONDecodable {
    
    init?(JSONValue: JSON.Value) {
        
        if let identifier = JSONValue.rawValue as? Int {
            
            self = .identifier(identifier)
            
        } else {
            
            guard let decodable = Value.init(JSONValue: JSONValue)
                else { return nil }
            
            self = .value(decodable)
        }
    }
}
