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
    
    func test_create_validVenue_returnsCorrectDTO() {
        // Arrange
        let venueListItemDTOAssembler = VenueListItemDTOAssembler()
        let venue = Venue()
        venue.id = 1
        venue.lat = "133.56"
        venue.long = "53.56"
        
        // Act
        let venueListItemDTO = venueListItemDTOAssembler.createDTO(venue)
        
        // Assert
        XCTAssertEqual(venue.id, venueListItemDTO.id)
        XCTAssertEqual(venue.name, venueListItemDTO.name)
        XCTAssertEqual(Double(venue.lat), venueListItemDTO.lat)
        XCTAssertEqual(Double(venue.long), venueListItemDTO.long)
    }
}
