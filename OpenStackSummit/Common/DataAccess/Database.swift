//
//  Database.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/20/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import RealmSwift

public class Database: NSObject {

    public var instance : Realm!
    
    public override init() {
        super.init()
        instance = try! Realm()
    }
    
    public init(instance : Realm) {
        self.instance = instance
    }
}
	