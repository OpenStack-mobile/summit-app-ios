//
//  DataUpdate.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/24/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public enum DataOperation {
    case Insert, Update, Delete
}

public class DataUpdate: BaseEntity {
    public var operation: DataOperation!
    public var date = NSDate(timeIntervalSince1970: 1)
    public var entity: BaseEntity!
    public var entityClassName = ""
    
    public override static func ignoredProperties() -> [String] {
        return ["entity"]
    }
}
