//
//  TagDeserializer.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/18/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON

public class TagDeserializer: NamedEntityDeserializer, IDeserializer {
    public func deserialize(json : JSON) throws -> BaseEntity {
        try validateRequiredFields(["id"], inJson: json)

        let tag = Tag()
        tag.id = json["id"].intValue
        tag.name = json["tag"].string ?? ""
        
        assert(!tag.name.isEmpty)

        return tag
    }
}
