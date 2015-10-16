//
//  MemberDataStoreTests.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/20/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XCTest
import OpenStackSummit
import RealmSwift
import Mockingjay

class MemberDataStoreTests: XCTestCase {
    
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
    
    func test_getById_userExistOnLocalDatabase_ReturnsCorrectMember() {
        // Arrange
        let memberId = 1
        let member = Member()
        member.id = memberId
        realm.write {
            self.realm.add(member)
        }
        
        let expectation = expectationWithDescription("async load")
        let dataStoreAssembly = DataStoreAssembly().activate();
        let memberDataStore = dataStoreAssembly.memberDataStore() as! MemberDataStore
        
        // Act
        memberDataStore.getById(memberId){
            (result) in
            
            // Assert
            XCTAssertEqual(1, self.realm.objects(Member.self).count)
            let member = self.realm.objects(Member.self).first
            XCTAssertEqual(memberId, member?.id)
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func test_addEventToMemberShedule_succeedAddingEvent_ReturnsAddedEventAndNoError() {
        // Arrange
        var event = SummitEvent()
        event.id = 1
        realm.write {
            self.realm.add(event)
        }
        
        let expectation = expectationWithDescription("async load")
        let memberRemoteDataStoreMock = MemberRemoteDataStoreMock()
        let memberDataStore = MemberDataStore(memberRemoteStorage: memberRemoteDataStoreMock)
        let memberId = 1
        let member = Member()
        member.id = memberId
        member.attendeeRole = SummitAttendee()
        realm.write {
            self.realm.add(member)
        }
        event = self.realm.objects(SummitEvent.self).filter("id = \(1)").first!
        
        // Act
        memberDataStore.addEventToMemberShedule(member, event: event) { member, error in
            // Assert
            XCTAssertEqual(1, self.realm.objects(Member.self).filter("id = \(memberId)").first!.attendeeRole!.scheduledEvents.first!.id)
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
}
