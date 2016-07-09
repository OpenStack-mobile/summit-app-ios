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
    
    @inline(__always)
    private func clearRealm() {
        
        //try! NSFileManager.defaultManager().removeItemAtPath(Store.shared.realm.configuration.path!)
        
        //try! Store.shared.realm.write { Store.shared.realm.deleteAll() }
    }
    
    func testCurrentSummitRequest() {
        
        clearRealm()
        
        let expectation = expectationWithDescription("API Request")
        
        Store.shared.summit() { (response) in
            
            switch response {
                
            case let .Error(error):
                
                XCTFail("\(error)");
                
            case let .Value(summit):
                
                XCTAssert(summit.speakers.isEmpty == false, "No Speakers")
                
                print(summit)
            }
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(60, handler: nil)
    }
    
    func testAustinSummitRequest() {
        
        clearRealm()
                
        let austinID = 6
        
        let expectation = expectationWithDescription("API Request")
        
        Store.shared.summit(austinID) { (response) in
            
            switch response {
                
            case let .Error(error):
                
                XCTFail("\(error)");
                
            case let .Value(summit):
                
                print(summit);
                
                XCTAssert(summit.speakers.isEmpty == false, "No Speakers")
                
                
            }
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(60, handler: nil)
    }
}