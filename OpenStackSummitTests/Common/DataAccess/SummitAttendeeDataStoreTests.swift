//
//  SummitAttendeeDataStoreTests.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/21/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XCTest
import OpenStackSummit
import RealmSwift

class SummitAttendeeDataStoreTests: XCTestCase {
    
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
    
    func test_addEventToMemberShedule_succeedAddingEvent_ReturnsAddedEventAndNoError() {
        // Arrange
        var event = SummitEvent()
        event.id = 1
        realm.write {
            self.realm.add(event)
        }
        
        let expectation = expectationWithDescription("async load")
        let summitAttendeeRemoteDataStoreMock = SummitAttendeeRemoteDataStoreMock()
        let summitAttendeeDataStore = SummitAttendeeDataStore(summitAttendeeRemoteDataStore: summitAttendeeRemoteDataStoreMock)
        let attendeeId = 1
        let attendee = SummitAttendee()
        attendee.id = attendeeId
        realm.write {
            self.realm.add(attendee)
        }
        event = self.realm.objects(SummitEvent.self).filter("id = \(1)").first!
        
        // Act
        summitAttendeeDataStore.addEventToMemberShedule(attendee, event: event) { member, error in
            // Assert
            XCTAssertEqual(1, self.realm.objects(SummitAttendee).filter("id = \(attendeeId)").first!.scheduledEvents.first!.id)
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
}
