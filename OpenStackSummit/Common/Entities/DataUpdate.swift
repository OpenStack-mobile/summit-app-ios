//
//  DataUpdate.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/24/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON

@objc public enum DataOperation: Int {
    case NoOp = -1, Insert, Update, Delete, Truncate
}

public class DataUpdate: BaseEntity {
    public dynamic var operation: DataOperation = .NoOp
    public dynamic var date = NSDate(timeIntervalSince1970: 1)
    public dynamic var entityClassName = ""
    public var originalJSON: JSON!
    public dynamic var entity: BaseEntity!
    
    public override static func ignoredProperties() -> [String] {
        return ["entity", "originalJSON"]
    }
}
