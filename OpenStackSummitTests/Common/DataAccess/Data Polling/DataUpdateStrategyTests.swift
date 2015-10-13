//
//  DataUpdateStrategy.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/29/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//


import XCTest
import OpenStackSummit
import RealmSwift

class DataUpdateStrategyTests: XCTestCase {
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
    
    func test_process_dataUpdateWithEventInsert_eventIsAddedToDatabase() {
        // Arrange
        let genericDataStore = GenericDataStore()
        let event = SummitEvent()
        event.id = 1
        
        let dataUpdateStrategy = DataUpdateStrategy(genericDataStore: genericDataStore)
        
        let dataUpdate = DataUpdate()
        dataUpdate.id = 1
        dataUpdate.operation = DataOperation.Insert
        dataUpdate.entity = event
        
        // Act
        try! dataUpdateStrategy.process(dataUpdate)
        
        // Assert
        XCTAssertEqual(1, realm.objects(SummitEvent).count)
    }
    
    func test_process_dataUpdateWithEventUpdate_eventIsUpdatedFromDatabase() {
        // Arrange
        let genericDataStore = GenericDataStore()
        let event = SummitEvent()
        event.id = 1
        realm.write {
            self.realm.add(event)
        }
        
        let eventUpdated = SummitEvent()
        eventUpdated.id = event.id
        eventUpdated.eventDescription = "test"
        eventUpdated.presentation = Presentation()
        eventUpdated.presentation?.level = "easy"
        
        let dataUpdateStrategy = DataUpdateStrategy(genericDataStore: genericDataStore)
        
        let dataUpdate = DataUpdate()
        dataUpdate.id = 1
        dataUpdate.operation = DataOperation.Update
        dataUpdate.entity = eventUpdated
        
        // Act
        try! dataUpdateStrategy.process(dataUpdate)
        
        // Assert
        let eventDB = realm.objects(SummitEvent).first!
        XCTAssertEqual(eventUpdated.eventDescription, eventDB.eventDescription)
        XCTAssertEqual(eventUpdated.presentation?.level, eventDB.presentation?.level)
    }

    func test_process_dataUpdateWithEventDelete_eventIsDeletedFromDatabase() {
        // Arrange
        let genericDataStore = GenericDataStore()
        let event1 = SummitEvent()
        event1.id = 1
        realm.write {
            self.realm.add(event1)
        }
        let event2 = SummitEvent()
        event2.id = 2
        realm.write {
            self.realm.add(event2)
        }
        
        let dataUpdateStrategy = DataUpdateStrategy(genericDataStore: genericDataStore)
        
        let dataUpdate = DataUpdate()
        dataUpdate.id = 1
        dataUpdate.operation = DataOperation.Delete
        dataUpdate.entity = event1
        
        // Act
        try! dataUpdateStrategy.process(dataUpdate)
        
        // Assert
        XCTAssertEqual(1, realm.objects(SummitEvent).count)
        XCTAssertEqual(0, realm.objects(SummitEvent).filter("id = %@", 1).count)
    }
    
}
