//
//  VenueListItemDTOAssemblerTests.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/16/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XCTest
import OpenStackSummit

class VenueListItemDTOAssemblerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_create_onlyAddressIsNotEmpty_returnsCorrectInstanceWithCorrectAddress() {
        // Arrange
        let venueListItemDTOAssembler = VenueListItemDTOAssembler()
        let venue = Venue()
        venue.id = 1
        venue.address = "3-13-1 Takanawa Minato, Tokyo 108-8612"
        
        // Act
        let venueListItemDTO = venueListItemDTOAssembler.createDTO(venue)
        
        // Assert
        XCTAssertEqual(venue.id, venueListItemDTO.id)
        XCTAssertEqual(venue.name, venueListItemDTO.name)
        XCTAssertEqual(venue.address, venueListItemDTO.address)
    }
    
    func test_create_addressAndCityIsNotEmpty_returnsCorrectInstanceWithCorrectAddress() {
        // Arrange
        let venueListItemDTOAssembler = VenueListItemDTOAssembler()
        let venue = Venue()
        venue.id = 1
        venue.address = "3-13-1 Takanawa Minato"
        venue.city = "Okinawa"
        
        // Act
        let venueListItemDTO = venueListItemDTOAssembler.createDTO(venue)
        
        // Assert
        XCTAssertEqual(venue.id, venueListItemDTO.id)
        XCTAssertEqual(venue.name, venueListItemDTO.name)
        XCTAssertEqual("3-13-1 Takanawa Minato, Okinawa", venueListItemDTO.address)
    }

    func test_create_addressAndCityAndZipCodeFieldIsNotEmpty_returnsCorrectInstanceWithCorrectAddress() {
        // Arrange
        let venueListItemDTOAssembler = VenueListItemDTOAssembler()
        let venue = Venue()
        venue.id = 1
        venue.address = "3-13-1 Takanawa Minato"
        venue.city = "Okinawa"
        venue.zipCode = "12345"
        
        // Act
        let venueListItemDTO = venueListItemDTOAssembler.createDTO(venue)
        
        // Assert
        XCTAssertEqual(venue.id, venueListItemDTO.id)
        XCTAssertEqual(venue.name, venueListItemDTO.name)
        XCTAssertEqual("3-13-1 Takanawa Minato, Okinawa (12345)", venueListItemDTO.address)
    }

    func test_create_noFieldIsEmpty_returnsCorrectInstanceWithCorrectAddress() {
        // Arrange
        let venueListItemDTOAssembler = VenueListItemDTOAssembler()
        let venue = Venue()
        venue.id = 1
        venue.address = "3-13-1 Takanawa Minato"
        venue.city = "Okinawa"
        venue.zipCode = "12345"
        venue.state = "Tokio"
        venue.country = "Japan"
        
        // Act
        let venueListItemDTO = venueListItemDTOAssembler.createDTO(venue)
        
        // Assert
        XCTAssertEqual(venue.id, venueListItemDTO.id)
        XCTAssertEqual(venue.name, venueListItemDTO.name)
        XCTAssertEqual("3-13-1 Takanawa Minato, Okinawa Tokio (12345), Japan", venueListItemDTO.address)
    }
    
}
