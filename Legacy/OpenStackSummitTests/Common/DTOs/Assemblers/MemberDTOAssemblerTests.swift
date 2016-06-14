//
//  MemberDTOAssemblerTests.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/27/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XCTest
import OpenStackSummit

class MemberDTOAssemblerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test_createDTO_memberThatIsAttendeeAndSpeaker_returnsDTOWithAttendeeAndSpeakerSet() {
        // Arrange
        let presentationSpeakerDTO = PresentationSpeakerDTO()
        let presentationSpeakerDTOAssemblerMock = PresentationSpeakerDTOAssemblerMock(presentationSpeakerDTO: presentationSpeakerDTO)
        let summitAttendeeDTO = SummitAttendeeDTO()
        let summitAttendeeDTOAssemblerMock = SummitAttendeeDTOAssemblerMock(summitAttendeeDTO: summitAttendeeDTO)
        let memberDTOAssembler = MemberDTOAssembler(presentationSpeakerDTOAssembler: presentationSpeakerDTOAssemblerMock, summitAttendeeDTOAssembler: summitAttendeeDTOAssemblerMock)
        let member = Member()
        member.id = 1
        member.attendeeRole = SummitAttendee()
        member.speakerRole = PresentationSpeaker()
        
        // Act
        let memberDTO = memberDTOAssembler.createDTO(member)
        
        // Assert
        XCTAssertEqual(member.id, memberDTO.id)
        XCTAssertEqual(presentationSpeakerDTO, memberDTO.speakerRole)
        XCTAssertEqual(summitAttendeeDTO, memberDTO.attendeeRole)
    }

    func test_createDTO_memberThatIsOnlySpeaker_returnsDTOWithSpeakerSet() {
        // Arrange
        let presentationSpeakerDTO = PresentationSpeakerDTO()
        let presentationSpeakerDTOAssemblerMock = PresentationSpeakerDTOAssemblerMock(presentationSpeakerDTO: presentationSpeakerDTO)
        let summitAttendeeDTO = SummitAttendeeDTO()
        let summitAttendeeDTOAssemblerMock = SummitAttendeeDTOAssemblerMock(summitAttendeeDTO: summitAttendeeDTO)
        let memberDTOAssembler = MemberDTOAssembler(presentationSpeakerDTOAssembler: presentationSpeakerDTOAssemblerMock, summitAttendeeDTOAssembler: summitAttendeeDTOAssemblerMock)
        let member = Member()
        member.id = 1
        member.speakerRole = PresentationSpeaker()
        
        // Act
        let memberDTO = memberDTOAssembler.createDTO(member)
        
        // Assert
        XCTAssertEqual(member.id, memberDTO.id)
        XCTAssertEqual(presentationSpeakerDTO, memberDTO.speakerRole)
        XCTAssertNil(memberDTO.attendeeRole)
    }
    
    func test_createDTO_memberThatIsOnlyAttendee_returnsDTOWithAttendeeSet() {
        // Arrange
        let presentationSpeakerDTO = PresentationSpeakerDTO()
        let presentationSpeakerDTOAssemblerMock = PresentationSpeakerDTOAssemblerMock(presentationSpeakerDTO: presentationSpeakerDTO)
        let summitAttendeeDTO = SummitAttendeeDTO()
        let summitAttendeeDTOAssemblerMock = SummitAttendeeDTOAssemblerMock(summitAttendeeDTO: summitAttendeeDTO)
        let memberDTOAssembler = MemberDTOAssembler(presentationSpeakerDTOAssembler: presentationSpeakerDTOAssemblerMock, summitAttendeeDTOAssembler: summitAttendeeDTOAssemblerMock)
        let member = Member()
        member.id = 1
        member.attendeeRole = SummitAttendee()
        
        // Act
        let memberDTO = memberDTOAssembler.createDTO(member)
        
        // Assert
        XCTAssertEqual(member.id, memberDTO.id)
        XCTAssertEqual(summitAttendeeDTO, memberDTO.attendeeRole)
        XCTAssertNil(memberDTO.speakerRole)
    }
    
}
