//
//  MemberDataStoreTests.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/20/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XCTest
import OpenStackSummit
import RealmSwift

class MemberDataStoreTests: XCTestCase {
    
    var realm = try! Realm()
    
    override func setUp() {
        super.setUp()
        
        try! realm.write {
            self.realm.deleteAll()
        }
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_getByIdLocal_userExistOnLocalDatabase_ReturnsCorrectMember() {
        // Arrange
        let memberId = 1
        let memberStored = Member()
        memberStored.id = memberId
        try! realm.write {
            self.realm.add(memberStored)
        }
        
        let dataStoreAssembly = DataStoreAssembly().activate();
        let memberDataStore = dataStoreAssembly.memberDataStore() as! MemberDataStore
        
        // Act
        let member = memberDataStore.getByIdLocal(memberId)
        
        XCTAssertEqual(memberId, member?.id)
    }
}
