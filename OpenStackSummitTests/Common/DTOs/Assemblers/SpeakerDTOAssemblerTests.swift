//
//  SpeakerDTOAssemblerTests.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/1/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XCTest
import OpenStackSummit

class SpeakerDTOAssemblerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test_createDTO_speakerThatIsNotPresentationOwner_returnsDTOWithCorrectData() {
        // Arrange
        let speaker = Member()
        speaker.firstName = "Enzo"
        speaker.lastName = "Francescoli"
        speaker.speakerRole = PresentationSpeaker()
        speaker.speakerRole!.isPresentationOwner = false
        
        let speakerDTOAssembler = SpeakerDTOAssembler()
        
        // Act
        let speakerDTO = speakerDTOAssembler.createDTO(speaker)
        
        // Assert
        XCTAssertEqual(speaker.firstName + " " + speaker.lastName, speakerDTO.name)
        XCTAssertEqual(speaker.speakerRole!.isPresentationOwner, speakerDTO.isPresentationOwner)
    }
    
    func test_createDTO_speakerThatIsPresentationOwner_returnsDTOWithCorrectData() {
        // Arrange
        let speaker = Member()
        speaker.firstName = "Enzo"
        speaker.lastName = "Francescoli"
        speaker.speakerRole = PresentationSpeaker()
        speaker.speakerRole!.isPresentationOwner = true
        
        let speakerDTOAssembler = SpeakerDTOAssembler()
        
        // Act
        let speakerDTO = speakerDTOAssembler.createDTO(speaker)
        
        // Assert
        XCTAssertEqual(speaker.firstName + " " + speaker.lastName, speakerDTO.name)
        XCTAssertEqual(speaker.speakerRole!.isPresentationOwner, speakerDTO.isPresentationOwner)
    }
}
