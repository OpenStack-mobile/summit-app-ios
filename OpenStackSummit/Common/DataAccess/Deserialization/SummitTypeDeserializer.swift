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
            guard let check: SummitType = deserializerStorage.get(summitTypeId) else {
                throw DeserializerError.EntityNotFound("Summit type with id \(summitTypeId) not found on deserializer storage")
            }
            summitType = check
        }
        else {
            try validateRequiredFields(["id"], inJson: json)
            
            summitType = super.deserialize(json) as SummitType
            summitType.color = json["color"].string ?? ""
            if(!deserializerStorage.exist(summitType)) {
                deserializerStorage.add(summitType)
            }
        }
        
        return summitType
    }
}
