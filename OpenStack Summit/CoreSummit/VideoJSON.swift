//
//  VideoJSON.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 8/16/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import JSON

public extension Video {
    
    enum JSONKey: String {
        
        case id, name, description, display_on_site, featured, presentation_id, youtube_id, data_uploaded, highlighted, views, order
    }
}

extension Video: JSONDecodable {
    
    public init?(json JSONValue: JSON.Value) {
        
        guard let JSONObject = JSONValue.objectValue,
            let identifier = JSONObject[JSONKey.id.rawValue]?.integerValue,
            let name = JSONObject[JSONKey.name.rawValue]?.rawValue as? String,
            let featured = JSONObject[JSONKey.featured.rawValue]?.rawValue as? Bool,
            let displayOnSite = JSONObject[JSONKey.display_on_site.rawValue]?.rawValue as? Bool,
            /* let presentation = JSONObject[JSONKey.presentation_id.rawValue]?.integerValue, */
            let youtube = JSONObject[JSONKey.youtube_id.rawValue]?.rawValue as? String
            else { return nil }
        
        self.identifier = identifier
        self.featured = featured
        self.displayOnSite = displayOnSite
        self.event = presentation
        self.youtube = youtube
        self.dataUploaded = Date(timeIntervalSince1970: TimeInterval(dataUploaded))
        self.highlighted = highlighted
        self.views = views
        self.order = order
        
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
