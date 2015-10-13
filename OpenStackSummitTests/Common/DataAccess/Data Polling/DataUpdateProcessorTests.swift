//
//  DataUpdateProcessor.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/25/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XCTest
import OpenStackSummit
import RealmSwift

class DataUpdateProcessorTests: XCTestCase {
    var realm = try! Realm()
    
    override func setUp() {
        super.setUp()
        
        realm.write {
            self.realm.deleteAll()
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_process_dataWithTwoSummitEventInserts_twoSummitEventsWereInsertedOnDatabase() {
        // Arrange
        /*let dataUpdateDeserializerMock = DataUpdateDeserializerMock()
        let genericDataStore = GenericDataStore()
        let dataUpdateProcessor = DataUpdateProcessor(genericDataStore: genericDataStore, dataUpdateDeserializer: dataUpdateDeserializerMock)*/
        
        // Act
        //dataUpdateProcessor.process(
        
        // Assert
    }
}
