//
//  StoreTests.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/16/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import XCTest
import CoreSummit
import RealmSwift

final class StoreTests: XCTestCase {
    
    @inline(__always)
    private func clearRealm() {
        
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = "StoreTests"
        
        try! Store.shared.realm.write { Store.shared.realm.deleteAll() }
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
    
    func testFeedbackRequest() {
        
        clearRealm()
        
        let austinID = 6
        
        let eventID = 1
        
        let expectation = expectationWithDescription("API Request")
        
        Store.shared.feedback(austinID, event: eventID, page: 1, objectsPerPage: 10) { (response) in
            
            switch response {
                
            case let .Error(error):
                
                XCTFail("\(error)");
                
            case let .Value(value):
                
                print(value)
            }
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(60, handler: nil)
    }
}