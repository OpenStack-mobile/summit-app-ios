//
//  StoreTests.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/16/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import XCTest
import Foundation
import CoreData
import SwiftFoundation
@testable import CoreSummit

final class StoreTests: XCTestCase {
    
    func testAllSummitsRequest() {
        
        let store = try! createStore()
        
        let expectation = expectationWithDescription("API Request")
        
        store.summits() { (response) in
            
            switch response {
                
            case let .Error(error):
                
                XCTFail("\(error)");
                
            case let .Value(value):
                
                XCTAssert(value.items.isEmpty == false, "No summits")
                
                dump(value, "AllSummitsDump.txt")
            }
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(60, handler: nil)
    }
    
    func testCurrentSummitRequest() {
        
        let store = try! createStore()
        
        let expectation = expectationWithDescription("API Request")
        
        store.summit() { (response) in
            
            switch response {
                
            case let .Error(error):
                
                XCTFail("\(error)");
                
            case let .Value(summit):
                                
                dump(summit, "CurrentSummitDump.txt")
            }
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(60, handler: nil)
    }
    
    func testPastSummitsRequest() {
        
        let store = try! createStore()
                
        let pastSummits = 7 ... 7
        
        for summitID in pastSummits {
            
            let expectation = expectationWithDescription("API Request")
            
            store.summit(summitID) { (response) in
                
                switch response {
                    
                case let .Error(error):
                    
                    XCTFail("\(error)");
                    
                case let .Value(summit):
                    
                    XCTAssert(summit.speakers.isEmpty == false, "No Speakers")
                    
                    dump(summit, "Summit" + "\(summitID)" + "Dump.txt")
                }
                
                expectation.fulfill()
            }
            
            waitForExpectationsWithTimeout(60, handler: nil)
        }
    }
    
    func testDataUpdatesRequest() {
        
        let store = try! createStore()
        
        let summitID = 7  // Barcelona
        
        let date = Date() - (60*60*24*30) // last month
        
        let expectation = expectationWithDescription("API Request")
        
        store.dataUpdates(summitID, from: date, limit: 100) { (response) in
            
            switch response {
                
            case let .Error(error):
                
                XCTFail("\(error)");
                
            case let .Value(value):
                
                XCTAssert(value.isEmpty == false)
            }
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(60, handler: nil)
    }
    
    func testFeedbackRequest() {
        
        let store = try! createStore()
        
        let summit = 7 // Barcelona
        
        let event = 16638 // Upstream University - Day 1
        
        let expectation = expectationWithDescription("API Request")
        
        store.feedback(summit, event: event, page: 1, objectsPerPage: 10) { (response) in
            
            switch response {
                
            case let .Error(error):
                
                XCTFail("\(error)");
                
            case let .Value(value):
                
                if value.total > 0 {
                    
                    XCTAssert(value.items.isEmpty == false)
                }
            }
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(60, handler: nil)
    }
    
    func testListMembersRequest() {
        
        let store = try! createStore()
        
        let expectation = expectationWithDescription("API Request")
        
        store.members(MemberListRequest.Filter(value: "Jimmy", property: .firstName)) { (response) in
            
            switch response {
                
            case let .Error(error):
                
                XCTFail("\(error)");
                
            case let .Value(value):
                
                if value.total > 0 {
                    
                    XCTAssert(value.items.isEmpty == false)
                }
            }
            
            expectation.fulfill()
        }
        
        waitForExpectationsWithTimeout(60, handler: nil)
    }
}
