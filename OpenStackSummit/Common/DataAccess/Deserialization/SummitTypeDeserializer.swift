//
//  SummitTypeDeserializer.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/15/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON

public class SummitTypeDeserializer: KeyValueDeserializer, DeserializerProtocol {
    
    var deserializerStorage: DeserializerStorage!
    
    public func deserialize(json : JSON) -> BaseEntity {
        let summitType : SummitType
        
        if let summitTypeId = json.int {
            summitType = deserializerStorage.get(summitTypeId)
        }
        else {
            summitType = super.deserialize(json) as SummitType
            if(!deserializerStorage.exist(summitType)) {
                deserializerStorage.add(summitType)
            }
        }
        
        return summitType
    }
}
