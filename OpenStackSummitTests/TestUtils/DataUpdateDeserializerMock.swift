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

    let dataUpdateArray: [DataUpdate]!
    let dataUpdate: DataUpdate!
    
    init(dataUpdateArray: [DataUpdate]) {
        self.dataUpdateArray = dataUpdateArray
    }
    
    func deserializeArray(json: String) throws -> [BaseEntity] {
        return dataUpdateArray
    }
}
