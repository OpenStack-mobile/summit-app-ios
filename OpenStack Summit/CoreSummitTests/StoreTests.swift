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
import Foundation
@testable import CoreSummit

final class StoreTests: XCTestCase {
    
    func testAllSummitsRequest() {
        
        let store = try! createStore()
        
        let expectation = self.expectation(description: "API Request")
        
        store.summits() { (response) in
            
            switch response {
                
            case let .error(error):
                
                XCTFail("\(error)");
                
            case let .value(value):
                
                XCTAssert(value.items.isEmpty == false, "No summits")
                
                dump(value, "StoreTestsAllSummitsDump.txt")
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 60, handler: nil)
    }
    
    func testCurrentSummitRequest() {
        
        let store = try! createStore()
        
        let expectation = self.expectation(description: "API Request")
        
        store.summit() { (response) in
            
            switch response {
                
            case let .error(error):
                
                XCTFail("\(error)");
                
            case let .value(summit):
                                
                dump(summit, "StoreTestsCurrentSummitDump.txt")
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 60, handler: nil)
    }
    
    func testSummitRequest() {
        
        let store = try! createStore()
        
        for summitID in SummitJSONIdentifiers {
            
            let expectation = self.expectation(description: "API Request")
            
            store.summit(summitID) { (response) in
                
                switch response {
                    
                case let .error(error):
                    
                    XCTFail("\(error)");
                    
                case let .value(summit):
                    
                    XCTAssert(summit.speakers.isEmpty == false, "No Events")
                    XCTAssert(summit.speakers.isEmpty == false, "No Speakers")
                    
                    dump(summit, "StoreTestsSummit" + "\(summitID)" + "Dump.txt")
                }
                
                expectation.fulfill()
            }
            
            waitForExpectations(timeout: 60, handler: nil)
        }
    }
    
    func testDataUpdatesRequest() {
        
        let store = try! createStore()
        
        let summitID: Identifier = 22  // Boston 2017
        
        let date = Date() - (60*60*24*30) // last month
        
        let expectation = self.expectation(description: "API Request")
        
        store.dataUpdates(summitID, from: date, limit: 100) { (response) in
            
            switch response {
                
            case let .error(error):
                
                XCTFail("\(error)");
                
            case .value:
                
                break
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 60, handler: nil)
    }
    
    func testFeedbackRequest() {
        
        let store = try! createStore()
        
        let summit: Identifier = 7 // Barcelona
        
        let event: Identifier = 16638 // Upstream University - Day 1
        
        let expectation = self.expectation(description: "API Request")
        
        store.feedback(summit, event: event, page: 1, objectsPerPage: 10) { (response) in
            
            switch response {
                
            case let .error(error):
                
                XCTFail("\(error)");
                
            case let .value(value):
                
                if value.total > 0 {
                    
                    XCTAssert(value.items.isEmpty == false)
                }
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 60, handler: nil)
    }
    
    func testListMembersRequest() {
        
        let store = try! createStore()
        
        let expectation = self.expectation(description: "API Request")
        
        store.members(MemberListRequest.Filter(value: "Jimmy", property: .firstName)) { (response) in
            
            switch response {
                
            case let .error(error):
                
                XCTFail("\(error)");
                
            case let .value(value):
                
                if value.total > 0 {
                    
                    XCTAssert(value.items.isEmpty == false)
                }
            }
            
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 60, handler: nil)
    }
}
