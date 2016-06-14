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
    
    func test_createDTO_validVenueWithTwoRooms_returnDTOWithTwoRooms() {
        // Arrange
        let venueRoomDTO = VenueRoomDTO()
        let venueRoomDTOAssemblerMock = VenueRoomDTOAssemblerMock(venueRoomDTO: venueRoomDTO)
        
        let venueDTOAssembler = VenueDTOAssembler(venueRoomDTOAssembler: venueRoomDTOAssemblerMock)
        let venue = Venue()
        venue.id = 1
        venue.name = "test venue"
        
        // Act
        let venueDTO = venueDTOAssembler.createDTO(venue)
        
        // Assert
        XCTAssertEqual(venue.id, venueDTO.id)
        XCTAssertEqual(venue.name, venueDTO.name)
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
    }

    func test_create_addressFieldIsNotEmpty_returnsCorrectInstanceWithCorrectAddress() {
        // Arrange
        let venueDTOAssembler = VenueDTOAssembler()
        let venue = Venue()
        venue.id = 1
        venue.address = "3-13-1 Takanawa Minato, Tokyo 108-8612"
        venue.lat = "133.56"
        venue.long = "53.56"
        
        // Act
        let venueDTO = venueDTOAssembler.createDTO(venue)
        
        // Assert
        XCTAssertEqual(venue.id, venueDTO.id)
        XCTAssertEqual(venue.name, venueDTO.name)
        XCTAssertEqual(venue.address, venueDTO.address)
        XCTAssertEqual(Double(venue.lat), venueDTO.lat)
        XCTAssertEqual(Double(venue.long), venueDTO.long)
    }
    
    func test_create_addressAndCityIsNotEmpty_returnsCorrectInstanceWithCorrectAddress() {
        // Arrange
        let venueDTOAssembler = VenueDTOAssembler()
        let venue = Venue()
        venue.id = 1
        venue.address = "3-13-1 Takanawa Minato"
        venue.city = "Okinawa"
        venue.lat = "133.56"
        venue.long = "-53.56"
        
        // Act
        let venueDTO = venueDTOAssembler.createDTO(venue)
        
        // Assert
        XCTAssertEqual(venue.id, venueDTO.id)
        XCTAssertEqual(venue.name, venueDTO.name)
        XCTAssertEqual("3-13-1 Takanawa Minato, Okinawa", venueDTO.address)
        XCTAssertEqual(Double(venue.lat), venueDTO.lat)
        XCTAssertEqual(Double(venue.long), venueDTO.long)
    }
    
    func test_create_addressAndCityAndZipCodeFieldIsNotEmpty_returnsCorrectInstanceWithCorrectAddress() {
        // Arrange
        let venueDTOAssembler = VenueDTOAssembler()
        let venue = Venue()
        venue.id = 1
        venue.address = "3-13-1 Takanawa Minato"
        venue.city = "Okinawa"
        venue.zipCode = "12345"
        venue.lat = "133.56"
        venue.long = "-53.56"
        
        // Act
        let venueDTO = venueDTOAssembler.createDTO(venue)
        
        // Assert
        XCTAssertEqual(venue.id, venueDTO.id)
        XCTAssertEqual(venue.name, venueDTO.name)
        XCTAssertEqual("3-13-1 Takanawa Minato, Okinawa (12345)", venueDTO.address)
        XCTAssertEqual(Double(venue.lat), venueDTO.lat)
        XCTAssertEqual(Double(venue.long), venueDTO.long)
    }
    
    func test_create_noLocationFieldIsEmpty_returnsCorrectInstanceWithCorrectAddress() {
        // Arrange
        let venueDTOAssembler = VenueDTOAssembler()
        let venue = Venue()
        venue.id = 1
        venue.address = "3-13-1 Takanawa Minato"
        venue.city = "Okinawa"
        venue.zipCode = "12345"
        venue.state = "Tokio"
        venue.country = "Japan"
        venue.lat = "133.56"
        venue.long = "-53.56"
        
        // Act
        let venueDTO = venueDTOAssembler.createDTO(venue)
        
        // Assert
        XCTAssertEqual(venue.id, venueDTO.id)
        XCTAssertEqual(venue.name, venueDTO.name)
        XCTAssertEqual("3-13-1 Takanawa Minato, Okinawa Tokio (12345), Japan", venueDTO.address)
        XCTAssertEqual(Double(venue.lat), venueDTO.lat)
        XCTAssertEqual(Double(venue.long), venueDTO.long)
    }
    
}
