//
//  DataUpdateDataStoreMock.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/28/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import OpenStackSummit

class DataUpdateDataStoreMock: DataUpdateDataStore {

    override func getLatestDataUpdate() -> DataUpdate? {
        return nil
    }
}
