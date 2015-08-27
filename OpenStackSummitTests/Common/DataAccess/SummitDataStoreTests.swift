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
    
    var realm = try! Realm()
    
    override func setUp() {
        super.setUp()
        
        realm.write {
            self.realm.deleteAll()
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_getActive_thereIsNoSummitOnLocalDatabase_returnsCorrectInstanceAfterLoadingFromRemote() {
        // Arrange
        let expectation = expectationWithDescription("async load")
        let summitDataStoreAssembly = SummitDataStoreAssembly().activate();
        let summitDataStore = summitDataStoreAssembly.summitDataStore() as! SummitDataStore
        			
        // Act
        summitDataStore.getActive(){
            (result) in
            
            // Assert
            XCTAssertEqual(1, self.realm.objects(Summit.self).count)
            let summit = self.realm.objects(Summit.self).first!
            XCTAssertEqual(1, summit.id)
            XCTAssertEqual(1, summit.venues.count)
            XCTAssertEqual("http://www.openstack.org/assets/paris-summit/_resampled/resizedimage464600-meridien-map-level01.png", summit.venues.first!.maps.first!.url)
            XCTAssertEqual("https://www.openstack.org/assets/paris-summit/_resampled/resizedimage464600-merdien-map-level02.png", summit.venues.first!.maps.last!.url)
            XCTAssertEqual(2, self.realm.objects(SummitType.self).count)
            XCTAssertEqual(2, self.realm.objects(SummitEvent.self).count)
            var summitEvent = self.realm.objects(SummitEvent.self).first!
            XCTAssertEqual(1, summitEvent.id)
            XCTAssertEqual(1, summitEvent.presentation?.id)
            XCTAssertEqual(3, summitEvent.presentation?.category.id)
            XCTAssertEqual(2, summitEvent.summitTypes.count)
            XCTAssertEqual(2, summitEvent.summitTypes.count)
            XCTAssertEqual(2, summitEvent.venueRoom!.id)
            
            summitEvent = self.realm.objects(SummitEvent.self).last!
            XCTAssertEqual(2, summitEvent.id)
            XCTAssertNil(summitEvent.presentation)
            XCTAssertNil(summitEvent.venueRoom)
            XCTAssertEqual(1, summitEvent.venue?.id)
            
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
    
    func test_getActive_thereIsOneSummitOnLocalDatabase_returnsCorrectInstanceFromLocalDatabase() {
        // Arrange
        let dummySummit = Summit()
        dummySummit.id = 2
        realm.write {
            self.realm.add(dummySummit)
        }
        
        let expectation = expectationWithDescription("async load")
        let summitDataStoreAssembly = SummitDataStoreAssembly().activate();
        let summitDataStore = summitDataStoreAssembly.summitDataStore() as! SummitDataStore
        
        // Act
        summitDataStore.getActive(){
            (result) in

            // Assert
            XCTAssertEqual(2, self.realm.objects(Summit.self).first!.id)
            
            expectation.fulfill()
        }
        
        self.waitForExpectationsWithTimeout(5.0, handler: nil)
    }
}
