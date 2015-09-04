//
//  ScheduleItemDTOAssemblerTests.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/3/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XCTest
import OpenStackSummit
import RealmSwift

class ScheduleItemDTOAssemblerTests: BaseTests {
        
    func test_createDTO_eventWithPresentationAndSpeakersThatNotFinished_returnsDTOWithCorrectData() {
        // Arrange
        let venue = Venue()
        venue.name = "Test Venue"
        let venueRoom = VenueRoom()
        venueRoom.name = "Test Venue Room"
        venue.venueRooms.append(venueRoom)
        realm.write {
            self.realm.add(venue)
        }
        let sponsor1 = Company()
        sponsor1.name = "sponsor1"
        let sponsor2 = Company()
        sponsor2.name = "sponsor2"
        let eventType = EventType()
        eventType.name = "Keynote"
        let event = SummitEvent()
        event.title = "Test Title"
        event.eventDescription = "Test Description"
        event.start = NSDate(timeIntervalSince1970: NSTimeInterval(1441137600))
        event.end = NSDate(timeIntervalSince1970: NSTimeInterval(1441141200))
        event.sponsors.append(sponsor1)
        event.sponsors.append(sponsor2)
        event.venueRoom = venueRoom
        
        let scheduleItemDTOAssembler = ScheduleItemDTOAssembler()
        
        // Act
        let scheduleItemDTO = scheduleItemDTOAssembler.createDTO(event)
        
        // Assert
        XCTAssertEqual(event.title, scheduleItemDTO.title)
        XCTAssertEqual(event.venueRoom!.venue.name + " - " + event.venueRoom!.name, scheduleItemDTO.location)
        XCTAssertEqual("Sponsored by sponsor1, sponsor2", scheduleItemDTO.sponsors)
        XCTAssertEqual("Tuesday 01 September 20:00 - 21:00", scheduleItemDTO.date)
        XCTAssertEqual(event.eventType.name, scheduleItemDTO.eventType)
    }
}
