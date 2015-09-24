//
//  MemberProfileInteractorTests.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/3/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XCTest
import OpenStackSummit

class MemberProfileInteractorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func test_isFullProfileAllowed_isCurrenUserProfile_returnsTrue() {
        // Arrange
        let member = Member()
        member.id = 1
        let securityManagerMock = SecurityManagerMock(member: member)
        let interactor = MemberProfileInteractor(memberDataStore: MemberDataStoreMock(), securityManager: securityManagerMock)
        
        // Act
        let allowFull = interactor.isFullProfileAllowed(member)
        
        // Assert
        XCTAssertTrue(allowFull)
    }
    
    func test_isFullProfileAllowed_areFriends_returnsTrue() {
        // Arrange
        let member = Member()
        member.id = 1

        let currentMember = Member()
        currentMember.id = 2
        currentMember.friends.append(member)
        
        let securityManagerMock = SecurityManagerMock(member: currentMember)
        let interactor = MemberProfileInteractor(memberDataStore: MemberDataStoreMock(), securityManager: securityManagerMock)
        
        // Act
        let allowFull = interactor.isFullProfileAllowed(member)
        
        // Assert
        XCTAssertTrue(allowFull)
    }
    
    func test_isFullProfileAllowed_currentUserIsAnonymous_returnsTrue() {
        // Arrange
        let member = Member()
        member.id = 1
        member.attendeeRole = SummitAttendee()
        
        let securityManagerMock = SecurityManagerMock(member: nil)
        let interactor = MemberProfileInteractor(memberDataStore: MemberDataStoreMock(), securityManager: securityManagerMock)
        
        // Act
        let allowFull = interactor.isFullProfileAllowed(member)
        
        // Assert
        XCTAssertFalse(allowFull)
    }
}
