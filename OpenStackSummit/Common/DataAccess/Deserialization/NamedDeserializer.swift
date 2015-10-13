//
//  NamedEntityDeserializer.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/14/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON

public class NamedEntityDeserializer : NSObject {
    
    public func deserialize<T : NamedEntity>(element: JSON) -> T {
        let entity = T()
        
        entity.id = element["id"].intValue
        entity.name = element["name"].stringValue
        
        return entity
    }
}