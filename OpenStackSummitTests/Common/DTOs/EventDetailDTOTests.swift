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
        let scheduleItemDTO = ScheduleItemDTO()
        scheduleItemDTO.sponsors = "Sponsored bu sponsor1,sponsor1"
        scheduleItemDTO.date = "Tuesday 01 September 20:00 - 21:00"
        scheduleItemDTO.name = "test title"
        scheduleItemDTO.location = "venue"
        scheduleItemDTO.eventType = "Test Event Type"
        
        // Act
        let eventDetailDTO = EventDetailDTO(scheduleItemDTO: scheduleItemDTO)
        
        // Assert
        XCTAssertEqual(scheduleItemDTO.name, eventDetailDTO.name)
        XCTAssertEqual(scheduleItemDTO.location, eventDetailDTO.location)
        XCTAssertEqual(scheduleItemDTO.sponsors, eventDetailDTO.sponsors)
        XCTAssertEqual(scheduleItemDTO.date, eventDetailDTO.date)
        XCTAssertEqual(scheduleItemDTO.credentials, eventDetailDTO.credentials)
        XCTAssertEqual(scheduleItemDTO.eventType, eventDetailDTO.eventType)
    }
}
