//
//  LinkJSON.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 5/5/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import JSON

public extension Link {
    
    enum JSONKey: String {
        
        case id, name, description, display_on_site, featured, order, presentation_id, link
    }
}

extension Link: JSONDecodable {
    
    public init?(json JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.integerValue,
            let featured = JSONObject[JSONKey.featured.rawValue]?.rawValue as? Bool,
            let displayOnSite = JSONObject[JSONKey.display_on_site.rawValue]?.rawValue as? Bool,
            let presentation = JSONObject[JSONKey.presentation_id.rawValue]?.integerValue,
            let order = JSONObject[JSONKey.order.rawValue]?.integerValue,
            let link = JSONObject[JSONKey.link.rawValue]?.urlValue
            else { return nil }
        
        self.identifier = identifier
        self.featured = featured
        self.displayOnSite = displayOnSite
        self.event = presentation
        self.order = order
        self.link = link
        
        // optional
        self.name = JSONObject[JSONKey.name.rawValue]?.rawValue as? String ?? ""
        
        if let descriptionText = JSONObject[JSONKey.description.rawValue]?.rawValue as? String,
            descriptionText.isEmpty == false {
            
            self.descriptionText = descriptionText
            
        } else {
            
            self.descriptionText = nil
        }
    }
}
