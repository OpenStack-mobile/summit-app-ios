//
//  EventDetailAssemblerTests.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/1/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XCTest
import OpenStackSummit

class EventDetailDTOAssemblerTests: XCTestCase {
    
    class SpeakerDTOAssemblerMock : ISpeakerDTOAssembler {
        
        var speakerDTO: SpeakerDTO
        
        init(speakerDTO: SpeakerDTO) {
            self.speakerDTO = speakerDTO
        }
        
        @objc func createDTO(member: Member) -> SpeakerDTO {
            return speakerDTO
        }
    }
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_createDTO_eventWithPresentationAndSpeakersThatNotFinished_returnsDTOWithCorrectData() {
        // Arrange
        let speaker = Member()
        speaker.firstName = "Enzo"
        speaker.lastName = "Francescoli"
        let venue = Venue()
        venue.name = "Test Venue"
        let venueRoom = VenueRoom()
        venueRoom.name = "Test Venue Room"
        let presentationCategory = PresentationCategory()
        presentationCategory.name = "Keynote"
        let tag1 = Tag()
        tag1.name = "Infraestructure"
        let tag2 = Tag()
        tag2.name = "Cloud Services"
        let event = SummitEvent()
        event.title = "Test Title"
        event.eventDescription = "Test Description"
        event.start = NSDate(timeIntervalSince1970: NSTimeInterval(1441137600))
        event.end = NSDate(timeIntervalSince1970: NSTimeInterval(1441141200))
        event.presentation = Presentation()
        event.presentation?.speakers.append(speaker)
        event.presentation?.category = presentationCategory
        event.presentation?.tags.append(tag1)
        event.presentation?.tags.append(tag2)
        event.venue = venue
        event.venueRoom = venueRoom
        
        let speakerDTO = SpeakerDTO()
        let speakerDTOAssemblerMock = SpeakerDTOAssemblerMock(speakerDTO: speakerDTO)
        
        let eventDetailDTOAssembler = EventDetailDTOAssembler(speakerDTOAssembler: speakerDTOAssemblerMock)
        
        // Act
        let eventDetailDTO = eventDetailDTOAssembler.createDTO(event)
        
        // Assert
        XCTAssertEqual(event.title, eventDetailDTO.title)
        XCTAssertEqual(event.eventDescription, eventDetailDTO.eventDescription)
        XCTAssertEqual(event.venue!.name + " - " + event.venueRoom!.name, eventDetailDTO.location)
        XCTAssertEqual(event.presentation!.speakers.count, eventDetailDTO.speakers.count)
        XCTAssertEqual(speakerDTO, eventDetailDTO.speakers[0])
        XCTAssertTrue(eventDetailDTO.finished)
        XCTAssertEqual("Tuesday 01 September 20:00 - 21:00", eventDetailDTO.date)
        XCTAssertEqual(event.presentation!.category.name, eventDetailDTO.category)
        XCTAssertEqual(tag1.name + ", " + tag2.name, eventDetailDTO.tags)
    }
    
    func test_createDTO_eventWithoutPresentationAndSpeakersFinished_returnsDTOWithCorrectData() {
        // Arrange
        let venue = Venue()
        venue.name = "Test Venue"
        let event = SummitEvent()
        event.title = "Test Title"
        event.eventDescription = "Test Description"
        event.start = NSDate(timeIntervalSince1970: NSTimeInterval(32998046400))
        event.end = NSDate(timeIntervalSince1970: NSTimeInterval(32998050000))
        event.venue = venue
        
        let speakerDTO = SpeakerDTO()
        let speakerDTOAssemblerMock = SpeakerDTOAssemblerMock(speakerDTO: speakerDTO)
        
        let eventDetailDTOAssembler = EventDetailDTOAssembler(speakerDTOAssembler: speakerDTOAssemblerMock)
        
        // Act
        let eventDetailDTO = eventDetailDTOAssembler.createDTO(event)
        
        // Assert
        XCTAssertEqual(event.title, eventDetailDTO.title)
        XCTAssertEqual(event.eventDescription, eventDetailDTO.eventDescription)
        XCTAssertEqual(event.venue!.name, eventDetailDTO.location)
        XCTAssertEqual(0, eventDetailDTO.speakers.count)
        XCTAssertFalse(eventDetailDTO.finished)
        XCTAssertEqual("Friday 01 September 20:00 - 21:00", eventDetailDTO.date)
        XCTAssertEqual("", eventDetailDTO.category)
        XCTAssertEqual("", eventDetailDTO.tags)
    }
}
