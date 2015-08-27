//
//  PresentationCategoryDeserializer.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/17/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON

public class PresentationCategoryDeserializer: KeyValueDeserializer, IDeserializer {
    var deserializerStorage: DeserializerStorage!
    
    public func deserialize(json : JSON) -> BaseEntity {
        
        let presentationCategory : PresentationCategory
        
        if let presentationCategoryId = json.int {
            presentationCategory = deserializerStorage.get(presentationCategoryId)
        }
        else {
            presentationCategory = super.deserialize(json) as PresentationCategory
            if(!deserializerStorage.exist(presentationCategory)) {
                deserializerStorage.add(presentationCategory)
            }
        }
        
        return presentationCategory
    }
}
