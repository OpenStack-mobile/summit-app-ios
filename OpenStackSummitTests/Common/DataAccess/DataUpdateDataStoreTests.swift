//
//  DataUpdateDataStoreTests.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/27/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XCTest
import OpenStackSummit
import RealmSwift

class DataUpdateDataStoreTests: XCTestCase {
    var realm = try! Realm()
    
    override func setUp() {
        super.setUp()
        
        try! realm.write {
            self.realm.deleteAll()
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_getLatestDataUpdate_thereAreTwoDataUpdates_returnsLatestOne() {
        // Arrange
        var dataUpdate = DataUpdate()
        dataUpdate.id = 1
        try! realm.write {
            self.realm.add(dataUpdate)
        }

        dataUpdate = DataUpdate()
        dataUpdate.id = 2
        try! realm.write {
            self.realm.add(dataUpdate)
        }
        
        let dataUpdateDataStore = DataUpdateDataStore()
        
        // Act
        let latestDataUpdate = dataUpdateDataStore.getLatestDataUpdate()
        
        // Assert
        XCTAssertEqual(2, latestDataUpdate!.id)
    }
    
}
