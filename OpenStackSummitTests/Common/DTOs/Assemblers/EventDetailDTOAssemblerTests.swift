//
//  EventDetailAssemblerTests.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/1/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XCTest
import OpenStackSummit
import RealmSwift

class EventDetailDTOAssemblerTests: BaseTests {
    
    class SpeakerDTOAssemblerMock : IPresentationSpeakerDTOAssembler {
        
        var speakerDTO: PresentationSpeakerDTO
        
        init(speakerDTO: PresentationSpeakerDTO) {
            self.speakerDTO = speakerDTO
        }
        
        @objc func createDTO(member: PresentationSpeaker) -> PresentationSpeakerDTO {
            return speakerDTO
        }
    }
    
    func test_createDTO_eventWithPresentationAndSpeakersThatNotFinished_returnsDTOWithCorrectData() {
        // Arrange
        let speaker = PresentationSpeaker()
        speaker.firstName = "Enzo"
        speaker.lastName = "Francescoli"
        let venue = Venue()
        venue.id = 2
        venue.name = "Test Venue"
        let venueRoom = VenueRoom()
        venueRoom.id = 1
        venueRoom.name = "Test Venue Room"
        venue.venueRooms.append(venueRoom)
        try! realm.write {
            self.realm.add(venue)
        }
        let track = Track()
        track.name = "Keynote"
        let tag1 = Tag()
        tag1.name = "Infraestructure"
        let tag2 = Tag()
        tag2.name = "Cloud Services"
        let sponsor1 = Company()
        sponsor1.name = "sponsor1"
        let sponsor2 = Company()
        sponsor2.name = "sponsor2"
        let event = SummitEvent()
        event.name = "Test Title"
        event.eventDescription = "Test Description"
        event.start = NSDate(timeIntervalSince1970: NSTimeInterval(1441137600))
        event.end = NSDate(timeIntervalSince1970: NSTimeInterval(1441141200))
        event.allowFeedback = true
        event.sponsors.append(sponsor1)
        event.sponsors.append(sponsor2)
        event.presentation = Presentation()
        event.presentation?.speakers.append(speaker)
        event.presentation?.track = track
        event.presentation?.level = "Intermediate"
        event.tags.append(tag1)
        event.tags.append(tag2)
        event.venueRoom = venueRoom
        
        let speakerDTO = PresentationSpeakerDTO()
        let speakerDTOAssemblerMock = SpeakerDTOAssemblerMock(speakerDTO: speakerDTO)
        let scheduleItemDTO = ScheduleItemDTO()
        let scheduleItemDTOAssemblerMock = ScheduleItemDTOAssemblerMock(scheduleItemDTO: scheduleItemDTO)
        let eventDetailDTOAssembler = EventDetailDTOAssembler(speakerDTOAssembler: speakerDTOAssemblerMock, scheduleItemDTOAssembler: scheduleItemDTOAssemblerMock)
        
        // Act
        let eventDetailDTO = eventDetailDTOAssembler.createDTO(event)
        
        // Assert
        XCTAssertEqual(scheduleItemDTO.name, eventDetailDTO.name)
        XCTAssertEqual(event.eventDescription, eventDetailDTO.eventDescription)
        XCTAssertEqual(scheduleItemDTO.location, eventDetailDTO.location)
        XCTAssertEqual(scheduleItemDTO.sponsors, eventDetailDTO.sponsors)
        XCTAssertEqual(scheduleItemDTO.time, eventDetailDTO.time)
        XCTAssertEqual(scheduleItemDTO.dateTime, eventDetailDTO.dateTime)
        XCTAssertEqual(event.presentation!.speakers.count, eventDetailDTO.speakers.count)
        XCTAssertEqual(speakerDTO, eventDetailDTO.speakers[0])
        XCTAssertTrue(eventDetailDTO.finished)
        XCTAssertTrue(eventDetailDTO.allowFeedback)
        XCTAssertEqual(event.presentation!.track.name, eventDetailDTO.track)
        XCTAssertEqual(tag1.name + ", " + tag2.name, eventDetailDTO.tags)
        XCTAssertEqual(2, eventDetailDTO.venueId)
        XCTAssertNil(eventDetailDTO.moderator)
        XCTAssertEqual(event.presentation!.level + " Level", eventDetailDTO.level)
    }
    
    func test_createDTO_eventWithPresentationModerator_returnsDTOWithCorrectData() {
        // Arrange
        let speaker = PresentationSpeaker()
        speaker.firstName = "Enzo"
        speaker.lastName = "Francescoli"
        let venue = Venue()
        venue.id = 2
        venue.name = "Test Venue"
        let venueRoom = VenueRoom()
        venueRoom.id = 1
        venueRoom.name = "Test Venue Room"
        venue.venueRooms.append(venueRoom)
        try! realm.write {
            self.realm.add(venue)
        }
        let track = Track()
        track.name = "Keynote"
        let tag1 = Tag()
        tag1.name = "Infraestructure"
        let tag2 = Tag()
        tag2.name = "Cloud Services"
        let sponsor1 = Company()
        sponsor1.name = "sponsor1"
        let sponsor2 = Company()
        sponsor2.name = "sponsor2"
        let event = SummitEvent()
        event.name = "Test Title"
        event.eventDescription = "Test Description"
        event.start = NSDate(timeIntervalSince1970: NSTimeInterval(1441137600))
        event.end = NSDate(timeIntervalSince1970: NSTimeInterval(1441141200))
        event.allowFeedback = true
        event.sponsors.append(sponsor1)
        event.sponsors.append(sponsor2)
        event.presentation = Presentation()
        event.presentation?.speakers.append(speaker)
        event.presentation?.moderator = speaker
        event.presentation?.track = track
        event.presentation?.level = "Intermediate"
        event.tags.append(tag1)
        event.tags.append(tag2)
        event.venueRoom = venueRoom
        
        let speakerDTO = PresentationSpeakerDTO()
        let speakerDTOAssemblerMock = SpeakerDTOAssemblerMock(speakerDTO: speakerDTO)
        let scheduleItemDTO = ScheduleItemDTO()
        let scheduleItemDTOAssemblerMock = ScheduleItemDTOAssemblerMock(scheduleItemDTO: scheduleItemDTO)
        let eventDetailDTOAssembler = EventDetailDTOAssembler(speakerDTOAssembler: speakerDTOAssemblerMock, scheduleItemDTOAssembler: scheduleItemDTOAssemblerMock)
        
        // Act
        let eventDetailDTO = eventDetailDTOAssembler.createDTO(event)
        
        // Assert
        XCTAssertEqual(scheduleItemDTO.name, eventDetailDTO.name)
        XCTAssertEqual(event.eventDescription, eventDetailDTO.eventDescription)
        XCTAssertEqual(scheduleItemDTO.location, eventDetailDTO.location)
        XCTAssertEqual(scheduleItemDTO.sponsors, eventDetailDTO.sponsors)
        XCTAssertEqual(scheduleItemDTO.time, eventDetailDTO.time)
        XCTAssertEqual(scheduleItemDTO.dateTime, eventDetailDTO.dateTime)
        XCTAssertEqual(event.presentation!.speakers.count, eventDetailDTO.speakers.count)
        XCTAssertEqual(speakerDTO, eventDetailDTO.speakers[0])
        XCTAssertTrue(eventDetailDTO.finished)
        XCTAssertTrue(eventDetailDTO.allowFeedback)
        XCTAssertEqual(event.presentation!.track.name, eventDetailDTO.track)
        XCTAssertEqual(tag1.name + ", " + tag2.name, eventDetailDTO.tags)
        XCTAssertEqual(2, eventDetailDTO.venueId)
        XCTAssertEqual(speaker.id, eventDetailDTO.moderator?.id)
        XCTAssertEqual(event.presentation!.level + " Level", eventDetailDTO.level)
    }
    
    
    func test_createDTO_eventWithoutPresentationAndSpeakersThatFinished_returnsDTOWithCorrectData() {
        // Arrange
        let venue = Venue()
        venue.id = 1
        venue.name = "Test Venue"
        let event = SummitEvent()
        event.name = "Test Title"
        event.eventDescription = "Test Description"
        event.start = NSDate(timeIntervalSince1970: NSTimeInterval(1211137600))
        event.end = NSDate(timeIntervalSince1970: NSTimeInterval(1211141200))
        event.allowFeedback = true
        event.venue = venue
        
        let speakerDTO = PresentationSpeakerDTO()
        let speakerDTOAssemblerMock = SpeakerDTOAssemblerMock(speakerDTO: speakerDTO)
        let scheduleItemDTO = ScheduleItemDTO()
        let scheduleItemDTOAssemblerMock = ScheduleItemDTOAssemblerMock(scheduleItemDTO: scheduleItemDTO)
        let eventDetailDTOAssembler = EventDetailDTOAssembler(speakerDTOAssembler: speakerDTOAssemblerMock, scheduleItemDTOAssembler: scheduleItemDTOAssemblerMock)

        // Act
        let eventDetailDTO = eventDetailDTOAssembler.createDTO(event)
        
        // Assert
        XCTAssertEqual(scheduleItemDTO.name, eventDetailDTO.name)
        XCTAssertEqual(event.eventDescription, eventDetailDTO.eventDescription)
        XCTAssertEqual(scheduleItemDTO.location, eventDetailDTO.location)
        XCTAssertEqual(0, eventDetailDTO.speakers.count)
        XCTAssertTrue(eventDetailDTO.finished)
        XCTAssertTrue(eventDetailDTO.allowFeedback)        
        XCTAssertEqual(scheduleItemDTO.sponsors, eventDetailDTO.sponsors)
        XCTAssertEqual(scheduleItemDTO.time, eventDetailDTO.time)
        XCTAssertEqual(scheduleItemDTO.dateTime, eventDetailDTO.dateTime)
        XCTAssertEqual("", eventDetailDTO.track)
        XCTAssertEqual("", eventDetailDTO.tags)
        XCTAssertEqual(venue.id, eventDetailDTO.venueId)
        XCTAssertEqual(1, eventDetailDTO.venueId)
        XCTAssertNil(eventDetailDTO.moderator)
        XCTAssertEqual("", eventDetailDTO.level)
    }
}
