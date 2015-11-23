//
//  EventDataStoreTests.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/23/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XCTest
import OpenStackSummit
import RealmSwift

class EventDataStoreTests: XCTestCase {
    
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
    
    func test_getByFilterLocal_validDateRangeAndEventTypesIsNilAndSummitTypesIsNilAndTwoEventsMatch_ReturnsEventListWithTwoElements() {
        // Arrange
        var event = SummitEvent()
        
        event.id = 1
        event.start = NSDate(timeIntervalSince1970: 1443015330)
        event.end = NSDate(timeIntervalSince1970: 1443018930)
        
        try! realm.write {
            self.realm.add(event)
        }

        event = SummitEvent()
        event.id = 2
        event.start = NSDate(timeIntervalSince1970: 1443010330)
        event.end = NSDate(timeIntervalSince1970: 1443014930)

        try! realm.write {
            self.realm.add(event)
        }
        
        let eventDataStore = EventDataStore()
        let startDate = NSDate(timeIntervalSince1970: 1443010330)
        let endDate =  NSDate(timeIntervalSince1970: 1443018930)
        
        // Act
        let events = eventDataStore.getByFilterLocal(startDate, endDate: endDate, eventTypes: nil, summitTypes: nil, tracks: nil, tags:nil)
        
        // Assert
        XCTAssertEqual(2, events.count)
    }

    func test_getByFilterLocal_validDateRangeAndEventTypesIsNilAndSummitTypesIsNilAndNoEventsMatch_ReturnsEmptyEventList() {
        // Arrange
        var event = SummitEvent()
        
        event.id = 1
        event.start = NSDate(timeIntervalSince1970: 1443015330)
        event.end = NSDate(timeIntervalSince1970: 1443018930)
        
        try! realm.write {
            self.realm.add(event)
        }
        
        event = SummitEvent()
        event.id = 2
        event.start = NSDate(timeIntervalSince1970: 1443010330)
        event.end = NSDate(timeIntervalSince1970: 1443014930)
        
        try! realm.write {
            self.realm.add(event)
        }
        
        let eventDataStore = EventDataStore()
        let startDate = NSDate(timeIntervalSince1970: 1543010330)
        let endDate =  NSDate(timeIntervalSince1970: 1543018930)
        
        // Act
        let events = eventDataStore.getByFilterLocal(startDate, endDate: endDate, eventTypes: nil, summitTypes: nil, tracks:nil, tags: nil)
        
        // Assert
        XCTAssertEqual(0, events.count)
    }
    
    func test_getByFilterLocal_validDateRangeAndEventTypesContainsOneElementAndSummitTypesContainsOneElementAndOneEventMatch_ReturnsEventListWithOneElement() {
        // Arrange
        let summitType1 = SummitType()
        summitType1.id = 1
        let summitType2 = SummitType()
        summitType2.id = 2
        
        var event = SummitEvent()
        
        event.id = 1
        event.start = NSDate(timeIntervalSince1970: 1443015330)
        event.end = NSDate(timeIntervalSince1970: 1443018930)
        event.eventType = EventType()
        event.eventType!.id = 1
        event.summitTypes.append(summitType1)
        
        try! realm.write {
            self.realm.add(event)
        }
        
        event = SummitEvent()
        event.id = 2
        event.start = NSDate(timeIntervalSince1970: 1443010330)
        event.end = NSDate(timeIntervalSince1970: 1443014930)
        event.eventType = EventType()
        event.eventType!.id = 2
        event.summitTypes.append(summitType2)
        
        try! realm.write {
            self.realm.add(event)
        }
        
        let eventDataStore = EventDataStore()
        let startDate = NSDate(timeIntervalSince1970: 1443010330)
        let endDate =  NSDate(timeIntervalSince1970: 1443018930)
        let eventTypes = [2]
        let summitTypes = [2]
        
        // Act
        let events = eventDataStore.getByFilterLocal(startDate, endDate: endDate, eventTypes: eventTypes, summitTypes: summitTypes, tracks:nil, tags: nil)
        
        // Assert
        XCTAssertEqual(1, events.count)
    }
    
    func test_getByFilterLocal_validDateRangeAndEventTypesContainsOneElementAndSummitTypesContainsOneElementAndNoEventMatch_ReturnsEmptyList() {
        // Arrange
        let summitType1 = SummitType()
        summitType1.id = 1
        let summitType2 = SummitType()
        summitType2.id = 2
        
        var event = SummitEvent()
        
        event.id = 1
        event.start = NSDate(timeIntervalSince1970: 1443015330)
        event.end = NSDate(timeIntervalSince1970: 1443018930)
        event.eventType = EventType()
        event.eventType!.id = 1
        event.summitTypes.append(summitType1)
        
        try! realm.write {
            self.realm.add(event)
        }
        
        event = SummitEvent()
        event.id = 2
        event.start = NSDate(timeIntervalSince1970: 1443010330)
        event.end = NSDate(timeIntervalSince1970: 1443014930)
        event.eventType = EventType()
        event.eventType!.id = 2
        event.summitTypes.append(summitType2)
        
        try! realm.write {
            self.realm.add(event)
        }
        
        let eventDataStore = EventDataStore()
        let startDate = NSDate(timeIntervalSince1970: 1443010330)
        let endDate =  NSDate(timeIntervalSince1970: 1443018930)
        let eventTypes = [1]
        let summitTypes = [2]
        
        // Act
        let events = eventDataStore.getByFilterLocal(startDate, endDate: endDate, eventTypes: eventTypes, summitTypes: summitTypes, tracks:nil, tags: nil)
        
        // Assert
        XCTAssertEqual(0, events.count)
    }
    
    func test_getByFilterLocal_validDateRangeAndTagsContainsTwoElementsAndOneEventMatch_ReturnsEventListWithOneElement() {
        // Arrange
        let tag1 = Tag()
        tag1.id = 1
        tag1.name = "tag1"
        let tag2 = Tag()
        tag2.id = 2
        tag2.name = "tag2"
        
        var event = SummitEvent()
        
        event.id = 1
        event.start = NSDate(timeIntervalSince1970: 1443015330)
        event.end = NSDate(timeIntervalSince1970: 1443018930)
        event.eventType = EventType()
        event.eventType!.id = 1
        event.tags.append(tag1)
        event.tags.append(tag2)
        
        try! realm.write {
            self.realm.add(event)
        }
        
        event = SummitEvent()
        event.id = 2
        event.start = NSDate(timeIntervalSince1970: 1443010330)
        event.end = NSDate(timeIntervalSince1970: 1443014930)
        event.eventType = EventType()
        event.eventType!.id = 2
        
        try! realm.write {
            self.realm.add(event)
        }
        
        let eventDataStore = EventDataStore()
        let startDate = NSDate(timeIntervalSince1970: 1443010330)
        let endDate =  NSDate(timeIntervalSince1970: 1443018931)
        let tags = [tag1.name, tag2.name]
        
        // Act
        let events = eventDataStore.getByFilterLocal(startDate, endDate: endDate, eventTypes: nil, summitTypes: nil, tracks:nil, tags: tags)
        
        // Assert
        XCTAssertEqual(1, events.count)
    }
    
    func test_getByFilterLocal_validDateRangeAndTagsContainsTwoElementsAndNoEventMatch_ReturnsEmptyList() {
        // Arrange
        let tag1 = Tag()
        tag1.id = 1
        tag1.name = "tag1"
        let tag2 = Tag()
        tag2.id = 2
        tag2.name = "tag2"
        
        var event = SummitEvent()
        
        event.id = 1
        event.start = NSDate(timeIntervalSince1970: 1443015330)
        event.end = NSDate(timeIntervalSince1970: 1443018930)
        event.eventType = EventType()
        event.eventType!.id = 1
        
        try! realm.write {
            self.realm.add(event)
        }
        
        event = SummitEvent()
        event.id = 2
        event.start = NSDate(timeIntervalSince1970: 1443010330)
        event.end = NSDate(timeIntervalSince1970: 1443014930)
        event.eventType = EventType()
        event.eventType!.id = 2
        
        try! realm.write {
            self.realm.add(event)
        }
        
        let eventDataStore = EventDataStore()
        let startDate = NSDate(timeIntervalSince1970: 1443010330)
        let endDate =  NSDate(timeIntervalSince1970: 1443018931)
        let tags = [tag1.name, tag2.name]
        
        // Act
        let events = eventDataStore.getByFilterLocal(startDate, endDate: endDate, eventTypes: nil, summitTypes: nil, tracks:nil, tags: tags)
        
        // Assert
        XCTAssertEqual(0, events.count)
    }

    func test_getByFilterLocal_validDateRangeAndTagsContainsTwoElementsAndTwoEventsMatch_ReturnsEventListWithTwoElements() {
        // Arrange
        let tag1 = Tag()
        tag1.id = 1
        tag1.name = "tag1"
        let tag2 = Tag()
        tag2.id = 2
        tag2.name = "tag2"
        
        var event = SummitEvent()
        
        event.id = 1
        event.start = NSDate(timeIntervalSince1970: 1443015330)
        event.end = NSDate(timeIntervalSince1970: 1443018930)
        event.eventType = EventType()
        event.eventType!.id = 1
        event.tags.append(tag1)
        
        try! realm.write {
            self.realm.add(event)
        }
        
        event = SummitEvent()
        event.id = 2
        event.start = NSDate(timeIntervalSince1970: 1443010330)
        event.end = NSDate(timeIntervalSince1970: 1443014930)
        event.eventType = EventType()
        event.eventType!.id = 2
        event.tags.append(tag2)
        
        try! realm.write {
            self.realm.add(event)
        }
        
        let eventDataStore = EventDataStore()
        let startDate = NSDate(timeIntervalSince1970: 1443010330)
        let endDate =  NSDate(timeIntervalSince1970: 1443018931)
        let tags = [tag1.name, tag2.name]
        
        // Act
        let events = eventDataStore.getByFilterLocal(startDate, endDate: endDate, eventTypes: nil, summitTypes: nil, tracks:nil, tags: tags)
        
        // Assert
        XCTAssertEqual(2, events.count)
    }
    
}
