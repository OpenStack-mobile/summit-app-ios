//
//  FaultJSON.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 12/27/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import JSON

public extension Fault where Value: JSONDecodable {
    
    init?(json: JSON.Value) {
        
        if let identifier = json.integerValue {
            
            self = .identifier(identifier)
            
        } else {
            
            guard let decodable = Value.init(json: json)
                else { return nil }
            
            self = .value(decodable)
        }
    }
}
