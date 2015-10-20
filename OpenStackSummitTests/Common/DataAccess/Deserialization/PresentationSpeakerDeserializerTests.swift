//
//  PresentationSpeakerDeserializerTests.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/30/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XCTest
import OpenStackSummit
import SwiftyJSON

class PresentationSpeakerDeserializerTests: XCTestCase {
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_deserialize_completeAndValidJSON_returnsCorrectInstanceAndAddToDeserializerStorage() {
        //Arrange
        let dataStoreAssembly = DataStoreAssembly().activate();
        let deserializerStorage = dataStoreAssembly.deserializerStorage() as! DeserializerStorage
        let deserializer = PresentationSpeakerDeserializer(deserializerStorage: deserializerStorage)
        let json = "{\"id\":173,\"first_name\":\"Michael\",\"last_name\":\"Johnson\",\"title\":\"Software Engineer\",\"bio\":\"test bio\",\"irc\":\"test irc\",\"twitter\":\"test twitter\",\"member_id\":1,\"presentations\":[3591]}"
        
        
        //Act
        let presentationSpeaker = try! deserializer.deserialize(json) as! PresentationSpeaker
        
        //Assert
        XCTAssertEqual(173,presentationSpeaker.id)
        XCTAssertEqual("Michael",presentationSpeaker.firstName)
        XCTAssertEqual("Johnson",presentationSpeaker.lastName)
        XCTAssertEqual("Software Engineer",presentationSpeaker.title)
        XCTAssertEqual("test bio",presentationSpeaker.bio)
        XCTAssertEqual("test irc",presentationSpeaker.irc)
        XCTAssertEqual("test twitter",presentationSpeaker.twitter)
        XCTAssertEqual(1,presentationSpeaker.memberId)
        XCTAssertTrue(deserializerStorage.exist(presentationSpeaker))
    }
    
    func test_deserialize_onlyIdJSON_returnsCorrectInstance() {
        //Arrange
        let dataStoreAssembly = DataStoreAssembly().activate();
        let deserializerStorage = dataStoreAssembly.deserializerStorage() as! DeserializerStorage
        
        let deserializer = PresentationSpeakerDeserializer(deserializerStorage: deserializerStorage)
        let json = "173"
        let storedPresentationSpeaker = PresentationSpeaker()
        storedPresentationSpeaker.id = 173
        storedPresentationSpeaker.firstName = "test"
        deserializerStorage.add(storedPresentationSpeaker)
        
        //Act
        let presentationSpeaker = try! deserializer.deserialize(json) as! PresentationSpeaker
        
        //Assert
        XCTAssertEqual(173,presentationSpeaker.id)
        XCTAssertEqual("test",presentationSpeaker.firstName)
    }
    
    func test_deserialize_jsonWithAllManfatoryFieldsMissed_throwsBadFormatException() {
        //Arrange
        let dataStoreAssembly = DataStoreAssembly().activate();
        let deserializerStorage = dataStoreAssembly.deserializerStorage() as! DeserializerStorage
        
        let deserializer = PresentationSpeakerDeserializer(deserializerStorage: deserializerStorage)
        let json = "{}"
        let expectedExceptionCount = 1
        var exceptionCount = 0
        var errorMessage = ""
        
        //Act
        do {
            try deserializer.deserialize(json) as! PresentationSpeaker
        }
        catch DeserializerError.BadFormat(let em) {
            exceptionCount++
            errorMessage = em
        }
        catch {
            
        }
        
        //Assert
        XCTAssertEqual(expectedExceptionCount, exceptionCount)
        XCTAssertNotNil(errorMessage.rangeOfString("Following fields are missed: id, first_name, last_name"))
    }
}
