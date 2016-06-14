//
//  EventDetailDTOTests.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/3/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XCTest
import OpenStackSummit

class EventDetailDTOTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_contructor_dtoWithAllFieldsSet_propertiesAreSetFromDtoParameter() {
        // Arrange
        let ScheduleItem = ScheduleItem()
        ScheduleItem.sponsors = "Sponsored bu sponsor1,sponsor1"
        ScheduleItem.time = "20:00 - 21:00"
        ScheduleItem.dateTime = "Tuesday 01 September 20:00 - 21:00"
        ScheduleItem.name = "test title"
        ScheduleItem.location = "venue"
        ScheduleItem.eventType = "Test Event Type"
        
        // Act
        let eventDetailDTO = EventDetailDTO(ScheduleItem: ScheduleItem)
        
        // Assert
        XCTAssertEqual(ScheduleItem.name, eventDetailDTO.name)
        XCTAssertEqual(ScheduleItem.location, eventDetailDTO.location)
        XCTAssertEqual(ScheduleItem.sponsors, eventDetailDTO.sponsors)
        XCTAssertEqual(ScheduleItem.time, eventDetailDTO.time)
        XCTAssertEqual(ScheduleItem.dateTime, eventDetailDTO.dateTime)
        XCTAssertEqual(ScheduleItem.summitTypes, eventDetailDTO.summitTypes)
        XCTAssertEqual(ScheduleItem.eventType, eventDetailDTO.eventType)
    }
}
