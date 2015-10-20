//
//  SummitTypeDeserializer.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/15/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON

public class SummitTypeDeserializer: NamedEntityDeserializer, IDeserializer {
    
    var deserializerStorage: DeserializerStorage!
    
    public func deserialize(json : JSON) throws -> BaseEntity {
        let summitType : SummitType
        
        if let summitTypeId = json.int {
            summitType = deserializerStorage.get(summitTypeId)
        }
        else {
            try validateRequiredFields(["id", "name"], inJson: json)
            
            summitType = super.deserialize(json) as SummitType
            if(!deserializerStorage.exist(summitType)) {
                deserializerStorage.add(summitType)
            }
        }
        
        return summitType
    }
}
