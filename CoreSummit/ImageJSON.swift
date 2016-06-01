//
//  ImageJSON.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

public extension Image {
    
    enum JSONKey: String {
        
        case id, url
    }
}

extension Image: JSONDecodable {
    
    public init?(JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.rawValue as? Int,
            let url = JSONObject[JSONKey.url.rawValue]?.rawValue as? String
            else { return nil }
        
        self.identifier = identifier
        self.url = url
    }
}