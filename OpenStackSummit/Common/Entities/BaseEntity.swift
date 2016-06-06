//
//  RealmEntity.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/14/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import RealmSwift

public class RealmEntity: Object {
    public dynamic var id = 0
    
    public override class func primaryKey() -> String {
        return "id"
    }
}
