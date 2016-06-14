//
//  ScheduleItemAssemblerTests.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/3/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XCTest
import OpenStackSummit
import RealmSwift

class ScheduleItemAssemblerTests: XCTestCase {
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
    
   func test_createDTO_eventWithPresentationAndSpeakersThatNotFinished_returnsDTOWithCorrectData() {
        // Arrange
        let venue = Venue()
        venue.id = 1
        venue.name = "Test Venue"
        let venueRoom = VenueRoom()
        venueRoom.id = 1;
        venueRoom.name = "Test Venue Room"
        let sponsor1 = Company()
        sponsor1.id = 1
        sponsor1.name = "sponsor1"
        let sponsor2 = Company()
        sponsor2.id = 2
        sponsor2.name = "sponsor2"
        let eventType = EventType()
        eventType.id = 1
        eventType.name = "Keynote"
        let event = SummitEvent()
        event.id = 1
        event.name = "Test Title"
        event.eventDescription = "Test Description"
        event.start = NSDate(timeIntervalSince1970: NSTimeInterval(1441137600))
        event.end = NSDate(timeIntervalSince1970: NSTimeInterval(1441141200))
        event.sponsors.append(sponsor1)
        event.sponsors.append(sponsor2)
        event.venueRoom = venueRoom
        event.eventType = eventType
        
        let summit = Summit()
        summit.id = 1
        summit.events.append(event)
        summit.timeZone = "Asia/Tokyo"

        try! realm.write {
            self.realm.add(venue)
            self.realm.add(summit)
        }
        
        let ScheduleItemAssembler = ScheduleItemAssembler()
        
        // Act
        let ScheduleItem = ScheduleItemAssembler.createDTO(event)
        
        // Assert
        XCTAssertEqual(event.name, ScheduleItem.name)
        XCTAssertEqual(event.venueRoom!.venue.name + " - " + event.venueRoom!.name, ScheduleItem.location)
        XCTAssertEqual("Sponsored by sponsor1, sponsor2", ScheduleItem.sponsors)
        XCTAssertEqual("05:00 am / 06:00 am", ScheduleItem.time)
        XCTAssertEqual("Wednesday 02 September 05:00 am / 06:00 am", ScheduleItem.dateTime)
        XCTAssertEqual(event.eventType.name, ScheduleItem.eventType)
    }
    
    func test_createDTO_eventWithEndDateMidnight_returnsDTOWithCorrectData() {
        // Arrange
        let venue = Venue()
        venue.id = 1
        venue.name = "Test Venue"
        let venueRoom = VenueRoom()
        venueRoom.id = 1;
        venueRoom.name = "Test Venue Room"
        let sponsor1 = Company()
        sponsor1.id = 1
        sponsor1.name = "sponsor1"
        let sponsor2 = Company()
        sponsor2.id = 2
        sponsor2.name = "sponsor2"
        let eventType = EventType()
        eventType.id = 1
        eventType.name = "Keynote"
        let event = SummitEvent()
        event.id = 1
        event.name = "Test Title"
        event.eventDescription = "Test Description"
        event.start = NSDate(timeIntervalSince1970: NSTimeInterval(1446026400))
        event.end = NSDate(timeIntervalSince1970: NSTimeInterval(1446044400))
        event.sponsors.append(sponsor1)
        event.sponsors.append(sponsor2)
        event.venueRoom = venueRoom
        event.eventType = eventType

        let summit = Summit()
        summit.id = 1
        summit.events.append(event)
        summit.timeZone = "Asia/Tokyo"
        
        try! realm.write {
            self.realm.add(venue)
            self.realm.add(summit)
        }
        let ScheduleItemAssembler = ScheduleItemAssembler()
        
        // Act
        let ScheduleItem = ScheduleItemAssembler.createDTO(event)
        
        // Assert
        XCTAssertEqual(event.name, ScheduleItem.name)
        XCTAssertEqual(event.venueRoom!.venue.name + " - " + event.venueRoom!.name, ScheduleItem.location)
        XCTAssertEqual("Sponsored by sponsor1, sponsor2", ScheduleItem.sponsors)
        XCTAssertEqual("07:00 pm / 12:00 am", ScheduleItem.time)
        XCTAssertEqual("Wednesday 28 October 07:00 pm / 12:00 am", ScheduleItem.dateTime)
        XCTAssertEqual(event.eventType.name, ScheduleItem.eventType)
    }
    
    func test_createDTO_eventWithSingleSummitType_returnsDTOWithCorrectColorAssigned() {
        // Arrange
        let venue = Venue()
        venue.id = 1
        venue.name = "Test Venue"
        let venueRoom = VenueRoom()
        venueRoom.id = 1;
        venueRoom.name = "Test Venue Room"
        let eventType = EventType()
        eventType.id = 1
        eventType.name = "Keynote"

        let summitType = SummitType()
        summitType.id = 1
        summitType.color = "#ff4455"
        let event = SummitEvent()
        event.id = 1
        event.name = "Test Title"
        event.eventDescription = "Test Description"
        event.start = NSDate(timeIntervalSince1970: NSTimeInterval(1446026400))
        event.end = NSDate(timeIntervalSince1970: NSTimeInterval(1446044400))
        event.venueRoom = venueRoom
        event.eventType = eventType
        event.summitTypes.append(summitType)
        
        let summit = Summit()
        summit.id = 1
        summit.events.append(event)
        summit.timeZone = "Asia/Tokyo"
        
        try! realm.write {
            self.realm.add(venue)
            self.realm.add(summit)
        }
        let ScheduleItemAssembler = ScheduleItemAssembler()
        
        // Act
        let ScheduleItem = ScheduleItemAssembler.createDTO(event)
        
        // Assert
        XCTAssertEqual(summitType.color, ScheduleItem.trackGroupColor)
    }
}
