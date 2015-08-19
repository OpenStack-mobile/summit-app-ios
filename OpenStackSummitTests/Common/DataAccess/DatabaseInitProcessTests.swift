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

class DatabaseInitProcessTests: XCTestCase {
    
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
    
    func testInitDatabase() {
        // Arrange
        let databaseInitProcessAssembly = DatabaseInitProcessAssembly().activate();
        let databaseInitProcess = databaseInitProcessAssembly.databaseInitProcess()
        let realm = try! Realm()
        			
        // Act
        databaseInitProcess.runAsync()
        
        // Assert
        XCTAssertEqual(1, realm.objects(Summit.self).count)
        XCTAssertEqual(1, realm.objects(Summit.self).first!.id)
        XCTAssertEqual(2, realm.objects(SummitType.self).count)
        let summitEvent = realm.objects(SummitEvent.self).first!
        XCTAssertEqual(1, summitEvent.id)
        XCTAssertEqual(1, summitEvent.presentation?.id)
        XCTAssertEqual(3, summitEvent.presentation?.category.id)
        XCTAssertEqual(2, summitEvent.summitTypes.count)
        XCTAssertEqual(2, summitEvent.summitTypes.count)
        XCTAssertEqual(2, summitEvent.venueRoom!.id)
    }
}
