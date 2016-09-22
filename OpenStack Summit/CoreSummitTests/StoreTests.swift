//
//  StoreTests.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/16/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import XCTest
import SwiftFoundation
import RealmSwift
import CoreSummit

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
                
                dump(summit, "CurrentSummitDump.txt")
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
                
                dump(summit);
                
                XCTAssert(summit.speakers.isEmpty == false, "No Speakers")
            }
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(60, handler: nil)
    }
    /*
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
                
                dump(value)
            }
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(60, handler: nil)
    }*/
    
    func testDataUpdatesRequest() {
        
        clearRealm()
        
        let austinID = 6
        
        let date = Date() - (60*60*24*365) // last year
        
        let expectation = expectationWithDescription("API Request")
        
        Store.shared.dataUpdates(austinID, from: date, limit: 100) { (response) in
            
            switch response {
                
            case let .Error(error):
                
                XCTFail("\(error)");
                
            case let .Value(value):
                
                dump(value)
            }
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(60, handler: nil)
    }
}
