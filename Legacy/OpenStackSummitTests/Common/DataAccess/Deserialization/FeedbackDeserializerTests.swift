//
//  FeedbackDeserializerTests.swift
//  OpenStackSummit
//
//  Created by Claudio on 3/17/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import XCTest
import OpenStackSummit
import SwiftyJSON

class FeedbackDeserializerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_deserialize_completeAndValidJSONForInternalVenue_returnsCorrectInstance() {
        let dataStoreAssembly = DataStoreAssembly().activate();
        let deserializerStorage = dataStoreAssembly.deserializerStorage() as! DeserializerStorage
        
        let deserializerFactory = dataStoreAssembly.deserializerFactory() as! DeserializerFactory
        let deserializer = FeedbackDeserializer(deserializerStorage: deserializerStorage, deserializerFactory: deserializerFactory)
        let json = "{}"
        var exceptionCount = 0;
        let expectedExceptionCount = 1;
        
        //Act
        do {
            try deserializer.deserialize(json) as! Feedback
        }
        catch (DeserializerError.BadFormat(let _)) {
            exceptionCount++;
        }
        catch {
            
        }
        
        //Assert
        XCTAssertEqual(expectedExceptionCount, exceptionCount)
    }
}
