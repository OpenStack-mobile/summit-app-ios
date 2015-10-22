//
//  VenueDTOAssemblerTests.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/22/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XCTest
import OpenStackSummit

class VenueDTOAssemblerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_createDTO_validVenueWithTwoRooms_returnCorrectDTOWithTwoRooms() {
        // Arrange
        let venueRoomDTO = VenueRoomDTO()
        let venueRoomDTOAssemblerMock = VenueRoomDTOAssemblerMock(venueRoomDTO: venueRoomDTO)
        
        let venueDTOAssembler = VenueDTOAssembler(venueRoomDTOAssembler: venueRoomDTOAssemblerMock)
        let venue = Venue()
        venue.id = 1
        venue.name = "test venue"
        let venueRoom = VenueRoom()
        venue.venueRooms.append(venueRoom)
        venue.venueRooms.append(venueRoom)
        
        // Act
        let venueDTO = venueDTOAssembler.createDTO(venue)
        
        // Assert
        XCTAssertEqual(venue.id, venueDTO.id)
        XCTAssertEqual(venue.name, venueDTO.name)
        XCTAssertEqual(venue.venueRooms.count, venueDTO.rooms.count)
    }
    
    func test_createDTO_validVenueWithNoRooms_returnCorrectDTOWithNoRooms() {
        // Arrange
        let venueDTOAssembler = VenueDTOAssembler()
        let venue = Venue()
        venue.id = 1
        venue.name = "test venue"
        
        // Act
        let venueDTO = venueDTOAssembler.createDTO(venue)
        
        // Assert
        XCTAssertEqual(venue.id, venueDTO.id)
        XCTAssertEqual(venue.name, venueDTO.name)
        XCTAssertEqual(venue.venueRooms.count, venueDTO.rooms.count)
    }
    
}
