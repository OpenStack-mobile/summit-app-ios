//
//  MyScheduleDataUpdateStrategyTests.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/28/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XCTest
import OpenStackSummit
import RealmSwift

class MyScheduleDataUpdateStrategyTests: XCTestCase {
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
    
    func test_process_dataUpdateWithScheduleItemInsert_scheduleItemIsAddedToMemberSchedule() {
        // Arrange
        let memberDataStore = MemberDataStore()
        let member = Member()
        member.id = 1
        member.attendeeRole = SummitAttendee()
        try! realm.write {
            self.realm.add(member)
        }
        let event = SummitEvent()
        event.id = 1
        try! realm.write {
            self.realm.add(event)
        }
        
        let securityManagerMock = SecurityManagerMock(member: member)
        let myScheduleDataUpdateStrategy = MyScheduleDataUpdateStrategy(memberDataStore: memberDataStore, securityManager: securityManagerMock)
        
        let dataUpdate = DataUpdate()
        dataUpdate.id = 1
        dataUpdate.operation = DataOperation.Insert
        dataUpdate.entity = event
        
        // Act
        try! myScheduleDataUpdateStrategy.process(dataUpdate)
        
        // Assert
        XCTAssertEqual(1, realm.objects(Member).first!.attendeeRole?.scheduledEvents.count)
    }
    
    func test_process_dataUpdateWithScheduleItemDelete_scheduleItemIsDeletedFromMemberSchedule() {
        // Arrange
        let memberDataStore = MemberDataStore()
        let member = Member()
        member.id = 1
        member.attendeeRole = SummitAttendee()
        try! realm.write {
            self.realm.add(member)
        }
        let event1 = SummitEvent()
        event1.id = 1
        try! realm.write {
            self.realm.add(event1)
            member.attendeeRole?.scheduledEvents.append(event1)
        }
        let event2 = SummitEvent()
        event2.id = 2
        try! realm.write {
            self.realm.add(event2)
            member.attendeeRole?.scheduledEvents.append(event2)
        }

        let securityManagerMock = SecurityManagerMock(member: member)
        let myScheduleDataUpdateStrategy = MyScheduleDataUpdateStrategy(memberDataStore: memberDataStore, securityManager: securityManagerMock)
        
        let dataUpdate = DataUpdate()
        dataUpdate.id = 100
        dataUpdate.operation = DataOperation.Delete
        dataUpdate.entity = event1
        
        // Act
        try! myScheduleDataUpdateStrategy.process(dataUpdate)
        
        // Assert
        XCTAssertEqual(1, realm.objects(Member).first!.attendeeRole?.scheduledEvents.count)
        XCTAssertEqual(0, realm.objects(Member).first!.attendeeRole?.scheduledEvents.filter("id = %@", event1.id).count)
    }    
}
