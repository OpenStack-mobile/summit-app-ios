//
//  ImageJSON.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import JSON
import struct Foundation.URL

public extension Image {
    
    enum JSONKey: String {
        
        case id, image_url
    }
}

extension Image: JSONDecodable {
    
    public init?(json JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.integerValue,
            let urlString = JSONObject[JSONKey.image_url.rawValue]?.rawValue as? String,
            let url = URL(string: urlString)
            else { return nil }
        
        self.identifier = identifier
        self.url = url
    }
}
