//
//  VenueDeserializerTests.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/13/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XCTest
import OpenStackSummit
import SwiftyJSON

class VenueDeserializerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_deserialize_completeAndValidJSONForInternalVenue_returnsCorrectInstance() {
        //Arrange
        let dataStoreAssembly = DataStoreAssembly().activate();
        let deserializerStorage = dataStoreAssembly.deserializerStorage() as! DeserializerStorage
        
        let deserializerFactory = dataStoreAssembly.deserializerFactory() as! DeserializerFactory
        let deserializer = VenueDeserializer(deserializerStorage: deserializerStorage, deserializerFactory: deserializerFactory)
        let json = "{\"id\":19,\"name\":\"Grand Prince International Convention Center & Hotels\",\"description\":\"Convention Center\",\"class_name\":\"SummitVenue\",\"location_type\":\"Internal\",\"address_1\":\"3-13-1 Takanawa Minato, Tokyo 108-8612, Japan\",\"address_2\":null,\"zip_code\":\"12345\",\"city\":\"test city\",\"state\":\"Tokio\",\"country\":\"Japan\",\"lng\":\"139.73\",\"lat\":\"35.63\"}"
        
        //Act
        let venue = try! deserializer.deserialize(json) as! Venue
        
        //Assert
        XCTAssertEqual(19,venue.id)
        XCTAssertEqual("Grand Prince International Convention Center & Hotels",venue.name)
        XCTAssertEqual("Convention Center",venue.locationDescription)
        XCTAssertEqual("3-13-1 Takanawa Minato, Tokyo 108-8612, Japan",venue.address)
        XCTAssertEqual("test city",venue.city)
        XCTAssertEqual("Tokio",venue.state)
        XCTAssertEqual("Japan",venue.country)
        XCTAssertEqual("12345",venue.zipCode)
        XCTAssertEqual("35.63",venue.lat)
        XCTAssertEqual("139.73",venue.long)
        XCTAssertTrue(venue.isInternal)
    }

    func test_deserialize_completeAndValidJSONForExternalVenue_returnsCorrectInstanceWithIsInternalFalse() {
        //Arrange
        let dataStoreAssembly = DataStoreAssembly().activate();
        let deserializerStorage = dataStoreAssembly.deserializerStorage() as! DeserializerStorage
        
        let deserializerFactory = dataStoreAssembly.deserializerFactory() as! DeserializerFactory
        let deserializer = VenueDeserializer(deserializerStorage: deserializerStorage, deserializerFactory: deserializerFactory)
        let json = "{\"id\":19,\"name\":\"Grand Prince International Convention Center & Hotels\",\"description\":\"Convention Center\",\"class_name\":\"SummitVenue\",\"location_type\":\"External\",\"address_1\":\"3-13-1 Takanawa Minato, Tokyo 108-8612, Japan\",\"address_2\":null,\"zip_code\":null,\"city\":null,\"state\":null,\"country\":null,\"lng\":\"139.73\",\"lat\":\"35.63\"}"
        
        //Act
        let venue = try! deserializer.deserialize(json) as! Venue
        
        //Assert
        XCTAssertEqual(19,venue.id)
        XCTAssertFalse(venue.isInternal)
    }
    
    func test_deserialize_onlyID_returnsCorrectInstance() {
        //Arrange
        let dataStoreAssembly = DataStoreAssembly().activate();
        let deserializerStorage = dataStoreAssembly.deserializerStorage() as! DeserializerStorage
        
        let venueStored = Venue()
        venueStored.id = 1
        deserializerStorage.add(venueStored)
        
        let deserializerFactory = dataStoreAssembly.deserializerFactory() as! DeserializerFactory
        let deserializer = VenueDeserializer(deserializerStorage: deserializerStorage, deserializerFactory: deserializerFactory)
        let json = "1"
        
        //Act
        let venue = try! deserializer.deserialize(json) as! Venue
        
        //Assert
        XCTAssertEqual(venueStored.id,venue.id)
    }
}
