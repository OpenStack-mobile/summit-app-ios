//
//  SpeakerDTOAssemblerTests.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/1/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XCTest
import OpenStackSummit

class SpeakerDTOAssemblerTests: BaseTests {

    func test_createDTO_speakerThatIsNotPresentationOwner_returnsDTOWithCorrectData() {
        // Arrange
        let speaker = PresentationSpeaker()
        speaker.id = 1
        speaker.firstName = "Enzo"
        speaker.lastName = "Francescoli"
        speaker.isPresentationOwner = false
        
        let speakerDTOAssembler = SpeakerDTOAssembler()
        
        // Act
        let speakerDTO = speakerDTOAssembler.createDTO(speaker)
        
        // Assert
        XCTAssertEqual(speaker.id, speakerDTO.id)
        XCTAssertEqual(speaker.firstName + " " + speaker.lastName, speakerDTO.name)
    }
    
    func test_createDTO_speakerThatIsPresentationOwner_returnsDTOWithCorrectData() {
        // Arrange
        let speaker = PresentationSpeaker()
        speaker.id = 1
        speaker.firstName = "Enzo"
        speaker.lastName = "Francescoli"
        speaker.isPresentationOwner = true
        
        let speakerDTOAssembler = SpeakerDTOAssembler()
        
        // Act
        let speakerDTO = speakerDTOAssembler.createDTO(speaker)
        
        // Assert
        XCTAssertEqual(speaker.id, speakerDTO.id)
        XCTAssertEqual(speaker.firstName + " " + speaker.lastName, speakerDTO.name)
    }
}
