//
//  DatabaseInitProcess.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/17/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XCTest
import OpenStackSummit
import RealmSwift

class SummitDataStoreTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        let realm = try! Realm()
        realm.write {
            realm.deleteAll()
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_getAll_thereIsNoSummitOnLocalDatabase_returnsCorrectInstanceAfterLoadingFromRemote() {
        // Arrange
        let expectation = expectationWithDescription("async load")
        let summitDataStoreAssembly = SummitDataStoreAssembly().activate();
        let summitDataStore = summitDataStoreAssembly.summitDataStore() as! SummitDataStore
        let realm = try! Realm()
        			
        // Act
        summitDataStore.getAll(){
            (result) in
            
            // Assert
            XCTAssertEqual(1, realm.objects(Summit.self).count)
            XCTAssertEqual(1, realm.objects(Summit.self).first!.id)
            XCTAssertEqual(2, realm.objects(SummitType.self).count)
            XCTAssertEqual(2, realm.objects(SummitEvent.self).count)
            var summitEvent = realm.objects(SummitEvent.self).first!
            XCTAssertEqual(1, summitEvent.id)
            XCTAssertEqual(1, summitEvent.presentation?.id)
            XCTAssertEqual(3, summitEvent.presentation?.category.id)
            XCTAssertEqual(2, summitEvent.summitTypes.count)
            XCTAssertEqual(2, summitEvent.summitTypes.count)
            XCTAssertEqual(2, summitEvent.venueRoom!.id)
            
            summitEvent = realm.objects(SummitEvent.self).last!
            XCTAssertEqual(2, summitEvent.id)
            XCTAssertNil(summitEvent.presentation)
            XCTAssertNil(summitEvent.venueRoom)
            XCTAssertEqual(1, summitEvent.venue?.id)
            
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func test_getAll_thereIsOneSummitOnLocalDatabase_returnsCorrectInstanceFromLocalDatabase() {
        // Arrange
        let dummySummit = Summit()
        dummySummit.id = 2
        let realm = try! Realm()
        realm.write {
            realm.add(dummySummit)
        }
        
        let expectation = expectationWithDescription("async load")
        let summitDataStoreAssembly = SummitDataStoreAssembly().activate();
        let summitDataStore = summitDataStoreAssembly.summitDataStore() as! SummitDataStore
        
        // Act
        summitDataStore.getAll(){
            (result) in

            // Assert
            XCTAssertEqual(2, realm.objects(Summit.self).first!.id)
            
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
}
