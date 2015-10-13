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
        return super.deserialize(json) as Tag
    }
}
