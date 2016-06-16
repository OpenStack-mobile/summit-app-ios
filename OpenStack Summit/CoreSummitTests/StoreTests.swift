//
//  StoreTests.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/16/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import XCTest
import CoreSummit

final class StoreTests: XCTestCase {
    
    func testAustinSummitRequest() {
        
        let austinID = 6
        
        let expectation = expectationWithDescription("API Request")
        
        Store.shared.summit(austinID) { (response) in
            
            switch response {
                
            case let .Error(error):
                
                XCTFail("\(error)");
                
            case let .Value(value):
                
                print(value);
            }
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(60, handler: nil)
    }
    
    func testCurrentSummitRequest() {
        
        let expectation = expectationWithDescription("API Request")
        
        Store.shared.summit() { (response) in
            
            switch response {
                
            case let .Error(error):
                
                XCTFail("\(error)");
                
            case let .Value(value):
                
                print(value);
            }
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(60, handler: nil)
    }
}