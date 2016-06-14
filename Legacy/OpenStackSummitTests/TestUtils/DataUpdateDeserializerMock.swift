//
//  DataUpdateDeserializerMock.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/25/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import OpenStackSummit

class DataUpdateDeserializerMock: DataUpdateDeserializer {

    var dataUpdateArray: [DataUpdate]!
    var dataUpdate: DataUpdate!
    
    init(dataUpdateArray: [DataUpdate]) {
        super.init()
        self.dataUpdateArray = dataUpdateArray
    }
    
    func deserializeArray(json: String) throws -> [RealmEntity] {
        return dataUpdateArray
    }
}
