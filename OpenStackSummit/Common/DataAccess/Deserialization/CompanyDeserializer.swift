//
//  CompanyDeserializer.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/15/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON

public class CompanyDeserializer: KeyValueDeserializer, DeserializerProtocol {

    public func deserialize(json : JSON) -> BaseEntity {
        return super.deserialize(json) as Company
    }
}
