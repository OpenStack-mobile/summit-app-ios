//
//  Session.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/24/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol SessionProtocol{
    func get(key: String) -> AnyObject?
    func set(key: String, value: AnyObject)
}


public class Session: NSObject, SessionProtocol {
    public func get(key: String) -> AnyObject? {
        return NSUserDefaults.standardUserDefaults().objectForKey(key)
    }
    
    public func set(key: String, value: AnyObject) {
        NSUserDefaults.standardUserDefaults().setObject(value, forKey: key)
    }
}
