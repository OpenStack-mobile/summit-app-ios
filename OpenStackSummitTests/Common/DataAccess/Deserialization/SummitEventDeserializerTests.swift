//
//  SummitEventDeserializerTests.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/15/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XCTest
import OpenStackSummit
import SwiftyJSON

class SummitEventDeserializerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_Deserialize_completeJSONForPresentationAndVenueIsRoom_returnsCorrectInstance() {
        //Arrange
        let dataStoreAssembly = DataStoreAssembly().activate();
        let deserializerStorage = dataStoreAssembly.deserializerStorage() as! DeserializerStorage
        let track = Track();
        track.id = 2
        deserializerStorage.add(track)
        let venueRoom = VenueRoom()
        venueRoom.id = 19
        deserializerStorage.add(venueRoom)
        let eventType = EventType()
        eventType.id = 3
        deserializerStorage.add(eventType)
        let summitType = SummitType()
        summitType.id = 1
        deserializerStorage.add(summitType)
        let speaker1 = PresentationSpeaker()
        speaker1.id = 1761
        deserializerStorage.add(speaker1)
        let speaker2 = PresentationSpeaker()
        speaker2.id = 1861
        deserializerStorage.add(speaker2)
        
        let deserializerFactory = dataStoreAssembly.deserializerFactory() as! DeserializerFactory
        let deserializer = SummitEventDeserializer(deserializerStorage: deserializerStorage, deserializerFactory: deserializerFactory)
        let json = "{\"id\":5290,\"title\":\"Windows in OpenStack\",\"description\":\"test description\", \"start_date\":1446026400,\"end_date\":1446029100,\"location_id\":19,\"type_id\":3,\"class_name\":\"Presentation\",\"track_id\":2,\"level\":\"Beginner\",\"summit_types\":[1],\"sponsors\":[],\"speakers\":[1761,1861], \"allow_feedback\": true}"
        
        let data = json.dataUsingEncoding(NSUTF8StringEncoding)
        let jsonObject = JSON(data: data!)
        
        //Act
        let event = try! deserializer.deserialize(jsonObject) as! SummitEvent
        
        //Assert
        XCTAssertEqual(5290,event.id)
        XCTAssertEqual("Windows in OpenStack",event.name)
        XCTAssertEqual("test description",event.eventDescription)
        XCTAssertEqual(eventType.id,event.eventType.id)
        XCTAssertEqual(venueRoom.id,event.venueRoom!.id)
        XCTAssertEqual(2,event.presentation!.speakers.count)
        XCTAssertEqual(track.id, event.presentation!.track.id)
    }

    func test_Deserialize_CompleteJSONForPresentationAndVenueIsNotRoom_ReturnsCorrectInstance() {
        //Arrange
        let dataStoreAssembly = DataStoreAssembly().activate();
        let deserializerStorage = dataStoreAssembly.deserializerStorage() as! DeserializerStorage
        let track = Track();
        track.id = 2
        deserializerStorage.add(track)
        let venue = Venue()
        venue.id = 19
        deserializerStorage.add(venue)
        let eventType = EventType()
        eventType.id = 3
        deserializerStorage.add(eventType)
        let summitType = SummitType()
        summitType.id = 1
        deserializerStorage.add(summitType)
        let speaker1 = PresentationSpeaker()
        speaker1.id = 1761
        deserializerStorage.add(speaker1)
        let speaker2 = PresentationSpeaker()
        speaker2.id = 1861
        deserializerStorage.add(speaker2)
        
        let deserializerFactory = dataStoreAssembly.deserializerFactory() as! DeserializerFactory
        let deserializer = SummitEventDeserializer(deserializerStorage: deserializerStorage, deserializerFactory: deserializerFactory)
        let json = "{\"id\":5290,\"title\":\"Windows in OpenStack\",\"description\":\"test description\", \"start_date\":1446026400,\"end_date\":1446029100,\"location_id\":19,\"type_id\":3,\"class_name\":\"Presentation\",\"track_id\":2,\"level\":\"Beginner\",\"allow_feedback\": true,\"summit_types\":[1],\"sponsors\":[],\"speakers\":[1761,1861]}"
        
        //Act
        let event = try! deserializer.deserialize(json) as! SummitEvent
        
        //Assert
        XCTAssertEqual(5290,event.id)
        XCTAssertEqual("Windows in OpenStack",event.name)
        XCTAssertEqual("test description",event.eventDescription)
        XCTAssertEqual(eventType.id,event.eventType.id)
        XCTAssertEqual(venue.id,event.venue!.id)
        XCTAssertEqual(2,event.presentation?.speakers.count)
        XCTAssertEqual(track.id, event.presentation!.track.id)
        XCTAssertTrue(event.allowFeedback)
    }

    func test_deserialize_completeJSONForNonPresentationEventAndVenueIsRoom_returnsCorrectInstance() {
        //Arrange
        let dataStoreAssembly = DataStoreAssembly().activate();
        let deserializerStorage = dataStoreAssembly.deserializerStorage() as! DeserializerStorage
        let venueRoom = VenueRoom()
        venueRoom.id = 31
        deserializerStorage.add(venueRoom)
        let eventType = EventType()
        eventType.id = 6
        deserializerStorage.add(eventType)
        let summitType = SummitType()
        summitType.id = 1
        deserializerStorage.add(summitType)
        let sponsor = Company()
        sponsor.id = 59
        deserializerStorage.add(sponsor)
        
        let deserializerFactory = dataStoreAssembly.deserializerFactory() as! DeserializerFactory
        let deserializer = SummitEventDeserializer(deserializerStorage: deserializerStorage, deserializerFactory: deserializerFactory)
        let json = "{\"id\":6792,\"title\":\"Cisco Sponsor Session 1\",\"description\":null,\"start_date\":1445912100,\"end_date\":1445914500,\"location_id\":31,\"type_id\":6,\"class_name\":\"SummitEvent\",\"allow_feedback\":false,\"summit_types\":[1],\"sponsors\":[59]}"
        
        //Act
        let event = try! deserializer.deserialize(json) as! SummitEvent
        
        //Assert
        XCTAssertEqual(6792,event.id)
        XCTAssertEqual("Cisco Sponsor Session 1",event.name)
        XCTAssertEqual("",event.eventDescription)
        XCTAssertEqual(eventType.id,event.eventType.id)
        XCTAssertEqual(venueRoom.id,event.venueRoom!.id)
        XCTAssertNil(event.presentation)
        XCTAssertEqual(1, event.summitTypes.count)
        XCTAssertEqual(1, event.summitTypes.first!.id)
        XCTAssertEqual(1, event.sponsors.count)
        XCTAssertEqual(59, event.sponsors.first!.id)
        XCTAssertFalse(event.allowFeedback)
    }

    func test_deserialize_completeJSONAndLocationIsNotPresent_returnsCorrectInstanceWithoutAnyLocation() {
        //Arrange
        let dataStoreAssembly = DataStoreAssembly().activate();
        let deserializerStorage = dataStoreAssembly.deserializerStorage() as! DeserializerStorage
        let venueRoom = VenueRoom()
        venueRoom.id = 31
        deserializerStorage.add(venueRoom)
        let eventType = EventType()
        eventType.id = 6
        deserializerStorage.add(eventType)
        let summitType = SummitType()
        summitType.id = 1
        deserializerStorage.add(summitType)
        let sponsor = Company()
        sponsor.id = 59
        deserializerStorage.add(sponsor)
        
        let deserializerFactory = dataStoreAssembly.deserializerFactory() as! DeserializerFactory
        let deserializer = SummitEventDeserializer(deserializerStorage: deserializerStorage, deserializerFactory: deserializerFactory)
        let json = "{\"id\":6792,\"title\":\"Cisco Sponsor Session 1\",\"description\":null,\"start_date\":1445912100,\"end_date\":1445914500,\"location_id\":null,\"type_id\":6,\"class_name\":\"SummitEvent\",\"allow_feedback\":false,\"summit_types\":[1],\"sponsors\":[59]}"
        
        //Act
        let event = try! deserializer.deserialize(json) as! SummitEvent
        
        //Assert
        XCTAssertEqual(6792,event.id)
        XCTAssertEqual("Cisco Sponsor Session 1",event.name)
        XCTAssertNil(event.venue)
        XCTAssertNil(event.venueRoom)
    }
    
    func test_deserialize_jsonWithAllManfatoryFieldsMissed_throwsBadFormatException() {
        //Arrange
        let dataStoreAssembly = DataStoreAssembly().activate();
        let deserializerStorage = dataStoreAssembly.deserializerStorage() as! DeserializerStorage
        
        let deserializerFactory = dataStoreAssembly.deserializerFactory() as! DeserializerFactory
        let deserializer = SummitEventDeserializer(deserializerStorage: deserializerStorage, deserializerFactory: deserializerFactory)
        let json = "{}"
        let expectedExceptionCount = 1
        var exceptionCount = 0
        var errorMessage = ""
        
        //Act
        do {
            try deserializer.deserialize(json) as! SummitEvent
        }
        catch DeserializerError.BadFormat(let em) {
            exceptionCount++
            errorMessage = em
        }
        catch {
            
        }
        
        //Assert
        XCTAssertEqual(expectedExceptionCount, exceptionCount)
        XCTAssertNotNil(errorMessage.rangeOfString("Following fields are missed: id, start_date, end_date, title, allow_feedback, type_id"))
        
    }
}
