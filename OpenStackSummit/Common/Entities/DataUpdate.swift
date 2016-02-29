//
//  DataUpdate.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/24/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public enum DataOperation: Int {
    case Insert, Update, Delete, Truncate
}

public class DataUpdate: BaseEntity {
    private dynamic var rawOperation = -1
    public var opertation: DataOperation! {
        get {
            return DataOperation(rawValue: rawOperation)!
        }
        set {
            rawOperation = newValue.rawValue
        } 
    }
    public var date = NSDate(timeIntervalSince1970: 1)
    public var entity: BaseEntity!
    public var entityClassName = ""
    
    public override static func ignoredProperties() -> [String] {
        return ["entity"]
    }
}
