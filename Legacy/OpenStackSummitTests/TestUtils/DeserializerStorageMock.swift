//
//  DeserializerStorageMock.swift
//  OpenStackSummit
//
//  Created by Claudio on 1/14/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit
import OpenStackSummit

class DeserializerStorageMock: DeserializerStorage {

    var entity: RealmEntity?
    
    init(entity: RealmEntity?) {
        self.entity = entity
    }
    
    override func get<T : RealmEntity>(id: Int) -> T? {
        return entity as? T
    }
}
