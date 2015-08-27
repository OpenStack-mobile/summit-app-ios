//
//  TagDeserializer.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/18/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON

public class TagDeserializer: KeyValueDeserializer, IDeserializer {
    public func deserialize(json : JSON) -> BaseEntity {
        return super.deserialize(json) as Tag
    }
}
