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

    func test_createDTO_validSpeaker_returnsDTOWithCorrectData() {
        // Arrange
        let speaker = PresentationSpeaker()
        speaker.bio = "test bio"
        let personListDTOAssemblerMock = PersonListItemDTOAssemblerMock(personListItemDTO: PersonListItemDTO())
        let speakerDTOAssembler = PresentationSpeakerDTOAssembler(personListItemDTOAssembler: personListDTOAssemblerMock)
        
        // Act
        let speakerDTO = speakerDTOAssembler.createDTO(speaker)
        
        // Assert
        XCTAssertEqual(speaker.bio, speakerDTO.bio)
    }    
}
