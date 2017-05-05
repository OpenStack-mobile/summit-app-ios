//
//  SlideJSON.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 5/5/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import SwiftFoundation

public extension Slide {
    
    enum JSONKey: String {
        
        case id, name, description, display_on_site, featured, order, presentation_id, link
    }
}

extension Slide: JSONDecodable {
    
    public init?(JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.rawValue as? Int,
            let featured = JSONObject[JSONKey.featured.rawValue]?.rawValue as? Bool,
            let displayOnSite = JSONObject[JSONKey.display_on_site.rawValue]?.rawValue as? Bool,
            let presentation = JSONObject[JSONKey.presentation_id.rawValue]?.rawValue as? Identifier,
            let order = JSONObject[JSONKey.order.rawValue]?.rawValue as? Int,
            let link = JSONObject[JSONKey.link.rawValue]?.rawValue as? String
            else { return nil }
        
        self.identifier = identifier
        self.featured = featured
        self.displayOnSite = displayOnSite
        self.event = presentation
        self.order = order
        self.link = link
        
        // optional
        self.name = JSONObject[JSONKey.name.rawValue]?.rawValue as? String ?? ""
        
        if let descriptionText = JSONObject[JSONKey.description.rawValue]?.rawValue as? String
            where descriptionText.isEmpty == false {
            
            self.descriptionText = descriptionText
            
        } else {
            
            self.descriptionText = nil
        }
    }
}
