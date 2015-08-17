//
//  DeserializerTests.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/14/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XCTest
import OpenStackSummit

class DeserializerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDeserializeValidJSONReturnsCorrectSummitInstance() {
        //Arrange
        let deserializer = Deserializer()
        let json = "{\"summit\":{\"id\":1,\"name\":\"Tokio\",\"locations\":[{\"id\":1,\"name\":\"Grand Hotel\",\"address\":\"5th Avenue 4456\",\"lat\":\"45\",\"long\":\"33\",\"map\":\"http://map.com/image.jpg\"}],\"companies\":[{\"id\":1,\"name\":\"company1\"},{\"id\":1,\"name\":\"company1\"}],\"summitTypes\":[{\"id\":1,\"name\":\"main\"},{\"id\":2,\"name\":\"design\"}],\"eventTypes\":[{\"id\":1,\"name\":\"keynote\"},{\"id\":2,\"name\":\"presentation\"},{\"id\":3,\"name\":\"expo\"},{\"id\":4,\"name\":\"breakout\"}]}}"
        
        let data = json.dataUsingEncoding(NSUTF8StringEncoding)
        
        //Act
        let summit = deserializer.deserialize(data!)
        
        //Assert
        XCTAssertEqual(1,summit.id)
        XCTAssertEqual("Tokio",summit.name)
        XCTAssertEqual(2,summit.types.count)
    }
    
}
