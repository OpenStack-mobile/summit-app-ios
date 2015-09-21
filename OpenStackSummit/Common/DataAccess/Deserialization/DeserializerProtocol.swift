//
//  IDeserializer.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/15/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON

public protocol IDeserializer {
    func deserialize(json : JSON) throws -> BaseEntity
}
