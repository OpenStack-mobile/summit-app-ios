//
//  MenuInteractorTests.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/25/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XCTest
import OpenStackSummit

class MenuInteractorTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_getCurrentMemberRole_currentUserIsAnonymous_returnsAnonymous() {
        // Arrange
        let sessionMock = SessionMock()
        let interactor = MenuInteractor(session: sessionMock)
        
        // Act
        let role = interactor.getCurrentMemberRole()
        
        // Assert
        XCTAssertEqual(MemberRoles.Anonymous, role)
    }
    
    func test_getCurrentMemberRole_currentUserIsAttendee_returnsAttendee() {
        // Arrange
        let member = Member()
        member.attendeeRole = SummitAttendee()
        
        let sessionMock = SessionMock(member: member)
        let interactor = MenuInteractor(session: sessionMock)
        
        // Act
        let role = interactor.getCurrentMemberRole()
        
        // Assert
        XCTAssertEqual(MemberRoles.Attendee, role)
    }

    func test_getCurrentMemberRole_currentUserIsSpeaker_returnsSpeaker() {
        // Arrange
        let member = Member()
        member.attendeeRole = SummitAttendee()
        member.speakerRole = PresentationSpeaker()
        
        let sessionMock = SessionMock(member: member)
        let interactor = MenuInteractor(session: sessionMock)
        
        // Act
        let role = interactor.getCurrentMemberRole()
        
        // Assert
        XCTAssertEqual(MemberRoles.Speaker, role)
    }
}


