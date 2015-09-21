//
//  MemberProfileDTOAssembler.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/4/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XCTest
import OpenStackSummit
import RealmSwift

class MemberProfileDTOAssemblerTests: BaseTests {
    
    func test_createDTO_speakerMemberFull_returnsDTOWithCorrectData() {
        // Arrange
        let member = Member()
        member.firstName = "Enzo"
        member.lastName = "Francescoli"
        member.title = "Developer at River Plate"
        member.pictureUrl = "http://picture.com.ar"
        member.bio = "This is the bio"
        member.location = "Buenos Aires, Argentina"
        member.twitter = "@el_enzo"
        member.irc = "irc"
        member.speakerRole = PresentationSpeaker()
        member.attendeeRole = SummitAttendee()
        
        let event = SummitEvent()
        event.title = "Test Title"
        event.eventDescription = "Test Description"
        event.start = NSDate(timeIntervalSince1970: NSTimeInterval(1441137600))
        event.end = NSDate(timeIntervalSince1970: NSTimeInterval(1441141200))
        event.presentation = Presentation()
        event.presentation?.speakers.append(member.speakerRole!)

        member.attendeeRole!.scheduledEvents.append(event)
        
        realm.write {
            self.realm.add(member)
            self.realm.add(event)
        }

        let scheduleItemDTO = ScheduleItemDTO()
        let scheduleItemDTOAssemblerMock = ScheduleItemDTOAssemblerMock(scheduleItemDTO: scheduleItemDTO)
        let memberProfileDTOAssembler = MemberProfileDTOAssembler(scheduleItemDTOAssembler: scheduleItemDTOAssemblerMock)
        
        // Act
        let memberProfileDTO = memberProfileDTOAssembler.createDTO(member, full: true)
        
        // Assert
        XCTAssertEqual(member.firstName + " " + member.lastName, memberProfileDTO.name)
        XCTAssertEqual(member.title, memberProfileDTO.title)
        XCTAssertEqual(member.pictureUrl, memberProfileDTO.pictureUrl)
        XCTAssertEqual(member.bio, memberProfileDTO.bio)
        XCTAssertEqual(member.location, memberProfileDTO.location)
        XCTAssertEqual(member.twitter, memberProfileDTO.twitter)
        XCTAssertEqual(member.irc, memberProfileDTO.irc)
        XCTAssertEqual(1, memberProfileDTO.presentations.count)
        XCTAssertEqual(1, memberProfileDTO.scheduledEvents.count)
    }

    func test_createDTO_speakerMemberNotFull_returnsDTOWithCorrectData() {
        // Arrange
        let member = Member()
        member.firstName = "Enzo"
        member.lastName = "Francescoli"
        member.title = "Developer at River Plate"
        member.pictureUrl = "http://picture.com.ar"
        member.bio = "This is the bio"
        member.location = "Buenos Aires, Argentina"
        member.twitter = "@el_enzo"
        member.irc = "irc"
        member.speakerRole = PresentationSpeaker()
        member.attendeeRole = SummitAttendee()
        
        let event = SummitEvent()
        event.title = "Test Title"
        event.eventDescription = "Test Description"
        event.start = NSDate(timeIntervalSince1970: NSTimeInterval(1441137600))
        event.end = NSDate(timeIntervalSince1970: NSTimeInterval(1441141200))
        event.presentation = Presentation()
        event.presentation?.speakers.append(member.speakerRole!)
        
        member.attendeeRole!.scheduledEvents.append(event)
        
        realm.write {
            self.realm.add(member)
            self.realm.add(event)
        }
        
        let scheduleItemDTO = ScheduleItemDTO()
        let scheduleItemDTOAssemblerMock = ScheduleItemDTOAssemblerMock(scheduleItemDTO: scheduleItemDTO)
        let memberProfileDTOAssembler = MemberProfileDTOAssembler(scheduleItemDTOAssembler: scheduleItemDTOAssemblerMock)
        
        // Act
        let memberProfileDTO = memberProfileDTOAssembler.createDTO(member, full: false)
        
        // Assert
        XCTAssertEqual(member.firstName + " " + member.lastName, memberProfileDTO.name)
        XCTAssertEqual(member.title, memberProfileDTO.title)
        XCTAssertEqual(member.pictureUrl, memberProfileDTO.pictureUrl)
        XCTAssertEqual(member.bio, memberProfileDTO.bio)
        XCTAssertEqual("", memberProfileDTO.location)
        XCTAssertEqual("", memberProfileDTO.twitter)
        XCTAssertEqual("", memberProfileDTO.irc)
        XCTAssertEqual(1, memberProfileDTO.presentations.count)
        XCTAssertEqual(0, memberProfileDTO.scheduledEvents.count)
    }

    func test_createDTO_attendeeMemberNotFull_returnsDTOWithCorrectData() {
        // Arrange
        let member = Member()
        member.firstName = "Enzo"
        member.lastName = "Francescoli"
        member.title = "Developer at River Plate"
        member.pictureUrl = "http://picture.com.ar"
        member.bio = "This is the bio"
        member.location = "Buenos Aires, Argentina"
        member.twitter = "@el_enzo"
        member.irc = "irc"
        member.attendeeRole = SummitAttendee()
        
        let event = SummitEvent()
        event.title = "Test Title"
        event.eventDescription = "Test Description"
        event.start = NSDate(timeIntervalSince1970: NSTimeInterval(1441137600))
        event.end = NSDate(timeIntervalSince1970: NSTimeInterval(1441141200))
        
        member.attendeeRole!.scheduledEvents.append(event)
        
        realm.write {
            self.realm.add(member)
            self.realm.add(event)
        }
        
        let scheduleItemDTO = ScheduleItemDTO()
        let scheduleItemDTOAssemblerMock = ScheduleItemDTOAssemblerMock(scheduleItemDTO: scheduleItemDTO)
        let memberProfileDTOAssembler = MemberProfileDTOAssembler(scheduleItemDTOAssembler: scheduleItemDTOAssemblerMock)
        
        // Act
        let memberProfileDTO = memberProfileDTOAssembler.createDTO(member, full: false)
        
        // Assert
        XCTAssertEqual(member.firstName + " " + member.lastName, memberProfileDTO.name)
        XCTAssertEqual(member.title, memberProfileDTO.title)
        XCTAssertEqual(member.pictureUrl, memberProfileDTO.pictureUrl)
        XCTAssertEqual(member.bio, memberProfileDTO.bio)
        XCTAssertEqual("", memberProfileDTO.location)
        XCTAssertEqual("", memberProfileDTO.twitter)
        XCTAssertEqual("", memberProfileDTO.irc)
        XCTAssertEqual(0, memberProfileDTO.presentations.count)
        XCTAssertEqual(0, memberProfileDTO.scheduledEvents.count)
    }
}
