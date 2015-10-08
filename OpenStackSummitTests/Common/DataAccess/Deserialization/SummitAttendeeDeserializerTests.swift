//
//  SummitAttendeeDeserializer.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/6/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XCTest
import OpenStackSummit
import SwiftyJSON

class SummitAttendeeDeserializerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_deserialize_completeAndValidJSON_returnsCorrectInstance() {
        //Arrange
        let dataStoreAssembly = DataStoreAssembly().activate();
        let deserializerStorage = dataStoreAssembly.deserializerStorage() as! DeserializerStorage
        
        let tickerType = TicketType()
        tickerType.id = 1
        deserializerStorage.add(tickerType)
        let event1 = SummitEvent()
        event1.id = 6770
        deserializerStorage.add(event1)
        let event2 = SummitEvent()
        event2.id = 4982
        deserializerStorage.add(event2)
        
        let deserializerFactory = dataStoreAssembly.deserializerFactory() as! DeserializerFactory
        let deserializer = SummitAttendeeDeserializer(deserializerStorage: deserializerStorage, deserializerFactory: deserializerFactory)
        let json = "{\"id\":1,\"summit_hall_checked_in\":false,\"summit_hall_checked_in_date\":1444168328,\"shared_contact_info\":true,\"ticket_type_id\":1,\"member_id\":11624,\"schedule\":[\"6770\",\"4982\"],\"first_name\":\"TestFName\",\"last_name\":\"TestLName\",\"gender\":\"Male\",\"email\":\"test@tipit.net\",\"second_email\":null,\"third_email\":null,\"linked_in\":null,\"irc\":\"irc_test\",\"twitter\":\"twitter_test\",\"bio\":\"test bio\",\"title\":\"test title\"}"
        
        //Act
        let summitAttendee = try! deserializer.deserialize(json) as! SummitAttendee
        
        //Assert
        XCTAssertEqual(1,summitAttendee.id)
        XCTAssertEqual("TestFName",summitAttendee.firstName)
        XCTAssertEqual("TestLName",summitAttendee.lastName)
        XCTAssertEqual("test bio",summitAttendee.bio)
        XCTAssertEqual("test title",summitAttendee.title)
        XCTAssertEqual("twitter_test",summitAttendee.twitter)
        XCTAssertEqual("test@tipit.net",summitAttendee.email)
        XCTAssertEqual("irc_test",summitAttendee.irc)
        XCTAssertEqual(tickerType.id,summitAttendee.ticketType.id)
        XCTAssertEqual(2,summitAttendee.scheduledEvents.count)
    }
    
    func test_deserialize_onlyID_returnsCorrectInstance() {
        //Arrange
        let dataStoreAssembly = DataStoreAssembly().activate();
        let deserializerStorage = dataStoreAssembly.deserializerStorage() as! DeserializerStorage
        
        let summitAttendeeStored = SummitAttendee()
        summitAttendeeStored.id = 1
        deserializerStorage.add(summitAttendeeStored)
        
        let deserializerFactory = dataStoreAssembly.deserializerFactory() as! DeserializerFactory
        let deserializer = SummitAttendeeDeserializer(deserializerStorage: deserializerStorage, deserializerFactory: deserializerFactory)
        let json = "1"
        
        //Act
        let summitAttendee = try! deserializer.deserialize(json) as! SummitAttendee
        
        //Assert
        XCTAssertEqual(summitAttendeeStored.id,summitAttendee.id)
    }
    
    func test_deserialize_pageWithTwoAttendees_returnsListWithTwoPeople() {
        //Arrange
        let dataStoreAssembly = DataStoreAssembly().activate();
        let deserializerStorage = dataStoreAssembly.deserializerStorage() as! DeserializerStorage
        
        let deserializer = PresentationSpeakerDeserializer(deserializerStorage: deserializerStorage)
        let json = "{\"total\":1,\"per_page\":10,\"current_page\":1,\"last_page\":1,\"next_page_url\":null,\"prev_page_url\":null,\"from\":1,\"to\":1,\"data\":[{\"id\":1,\"summit_hall_checked_in\":false,\"summit_hall_checked_in_date\":1444231541,\"shared_contact_info\":true,\"ticket_type_id\":1,\"member_id\":11624,\"schedule\":[\"6770\",\"4982\",\"6763\",\"6813\",\"6799\",\"6056\",\"6792\",\"6816\",\"5879\"],\"first_name\":\"TestFN\",\"last_name\":\"TestLN\",\"gender\":\"Male\",\"email\":\"TestFN@tipit.net\",\"second_email\":null,\"third_email\":null,\"linked_in\":null,\"irc\":null,\"twitter\":null},{\"id\":2,\"summit_hall_checked_in\":false,\"summit_hall_checked_in_date\":1444231541,\"shared_contact_info\":true,\"ticket_type_id\":1,\"member_id\":11624,\"schedule\":[\"6770\",\"4982\",\"6763\",\"6813\",\"6799\",\"6056\",\"6792\",\"6816\",\"5879\"],\"first_name\":\"TestFN\",\"last_name\":\"TestLN\",\"gender\":\"Male\",\"email\":\"TestFN@tipit.net\",\"second_email\":null,\"third_email\":null,\"linked_in\":null,\"irc\":null,\"twitter\":null}]}"
        
        //Act
        let presentationSpeakers = try! deserializer.deserializePage(json) as! [PresentationSpeaker]
        
        //Assert
        XCTAssertEqual(2, presentationSpeakers.count)
    }
}
