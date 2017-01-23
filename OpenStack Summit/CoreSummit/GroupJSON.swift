//
//  GroupJSON.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 1/23/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import SwiftFoundation

private extension Group {
    
    enum JSONKey: String {
        
        case id, title, description, code
    }
}

extension Group: JSONDecodable {
    
    public init?(JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.rawValue as? Int,
            let title = JSONObject[JSONKey.title.rawValue]?.rawValue as? String,
            let code = JSONObject[JSONKey.code.rawValue]?.rawValue as? String
            else { return nil }
        
        self.identifier = identifier
        self.title = title
        self.code = code
        
        self.descriptionText = JSONObject[JSONKey.description.rawValue]?.rawValue as? String
    }
}
