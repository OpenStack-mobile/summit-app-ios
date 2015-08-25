//
//  MenuPresenterTests.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/25/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XCTest
import OpenStackSummit

class MenuPresenterTests: XCTestCase {
    
    class MenuInteractorMock : NSObject, IMenuInteractor {

        var role : MemberRoles!
        
        init(role: MemberRoles) {
            self.role = role
        }
        
        func getCurrentMemberRole() -> MemberRoles {
            return role
        }
    }
    
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_hasAccessToMenuItem_anonymousUser_returnCorrectValueForEachMenuItem() {
        // Arrange
        let menuInteractorMock = MenuInteractorMock(role: MemberRoles.Anonymous)
        let menuPresenter = MenuPresenter(interactor: menuInteractorMock, menuWireframe: MenuWireframe())
        
        // Act
        let resSection0Row0 = menuPresenter.hasAccessToMenuItem(0, row: 0)
        let resSection0Row1 = menuPresenter.hasAccessToMenuItem(0, row: 1)
        let resSection1Row0 = menuPresenter.hasAccessToMenuItem(1, row: 0)
        let resSection1Row1 = menuPresenter.hasAccessToMenuItem(1, row: 1)
        let resSection2Row0 = menuPresenter.hasAccessToMenuItem(2, row: 0)
        let resSection2Row1 = menuPresenter.hasAccessToMenuItem(2, row: 1)
        let resSection2Row2 = menuPresenter.hasAccessToMenuItem(2, row: 2)
        let resSection3Row0 = menuPresenter.hasAccessToMenuItem(3, row: 0)
        let resSection3Row1 = menuPresenter.hasAccessToMenuItem(3, row: 1)
        let resSection3Row2 = menuPresenter.hasAccessToMenuItem(3, row: 2)
        let resSection3Row3 = menuPresenter.hasAccessToMenuItem(3, row: 3)
        let resSection3Row4 = menuPresenter.hasAccessToMenuItem(3, row: 4)
        let resSection3Row5 = menuPresenter.hasAccessToMenuItem(3, row: 5)
        let resSection3Row6 = menuPresenter.hasAccessToMenuItem(3, row: 6)
        let resSection3Row7 = menuPresenter.hasAccessToMenuItem(3, row: 7)
        
        
        // Assert
        XCTAssertEqual(true, resSection0Row0)
        XCTAssertEqual(true, resSection0Row1)
        XCTAssertEqual(true, resSection1Row0)
        XCTAssertEqual(true, resSection1Row1)
        XCTAssertEqual(true, resSection2Row0)
        XCTAssertEqual(true, resSection2Row1)
        XCTAssertEqual(true, resSection2Row2)
        XCTAssertEqual(false, resSection3Row0)
        XCTAssertEqual(false, resSection3Row1)
        XCTAssertEqual(false, resSection3Row2)
        XCTAssertEqual(false, resSection3Row3)
        XCTAssertEqual(false, resSection3Row4)
        XCTAssertEqual(false, resSection3Row5)
        XCTAssertEqual(true, resSection3Row6)
        XCTAssertEqual(false, resSection3Row7)
    }
    
    func test_hasAccessToMenuItem_attendeeUser_returnCorrectValueForEachMenuItem() {
        //Arrange
        let menuInteractorMock = MenuInteractorMock(role: MemberRoles.Attendee)
        let menuPresenter = MenuPresenter(interactor: menuInteractorMock, menuWireframe: MenuWireframe())
        
        //Act
        let resSection0Row0 = menuPresenter.hasAccessToMenuItem(0, row: 0)
        let resSection0Row1 = menuPresenter.hasAccessToMenuItem(0, row: 1)
        let resSection1Row0 = menuPresenter.hasAccessToMenuItem(1, row: 0)
        let resSection1Row1 = menuPresenter.hasAccessToMenuItem(1, row: 1)
        let resSection2Row0 = menuPresenter.hasAccessToMenuItem(2, row: 0)
        let resSection2Row1 = menuPresenter.hasAccessToMenuItem(2, row: 1)
        let resSection2Row2 = menuPresenter.hasAccessToMenuItem(2, row: 2)
        let resSection3Row0 = menuPresenter.hasAccessToMenuItem(3, row: 0)
        let resSection3Row1 = menuPresenter.hasAccessToMenuItem(3, row: 1)
        let resSection3Row2 = menuPresenter.hasAccessToMenuItem(3, row: 2)
        let resSection3Row3 = menuPresenter.hasAccessToMenuItem(3, row: 3)
        let resSection3Row4 = menuPresenter.hasAccessToMenuItem(3, row: 4)
        let resSection3Row5 = menuPresenter.hasAccessToMenuItem(3, row: 5)
        let resSection3Row6 = menuPresenter.hasAccessToMenuItem(3, row: 6)
        let resSection3Row7 = menuPresenter.hasAccessToMenuItem(3, row: 7)
        
        
        //Assert
        XCTAssertEqual(true, resSection0Row0)
        XCTAssertEqual(true, resSection0Row1)
        XCTAssertEqual(true, resSection1Row0)
        XCTAssertEqual(true, resSection1Row1)
        XCTAssertEqual(true, resSection2Row0)
        XCTAssertEqual(true, resSection2Row1)
        XCTAssertEqual(true, resSection2Row2)
        XCTAssertEqual(true, resSection3Row0)
        XCTAssertEqual(true, resSection3Row1)
        XCTAssertEqual(false, resSection3Row2)
        XCTAssertEqual(true, resSection3Row3)
        XCTAssertEqual(false, resSection3Row4)
        XCTAssertEqual(true, resSection3Row5)
        XCTAssertEqual(false, resSection3Row6)
        XCTAssertEqual(true, resSection3Row7)
    }
    
    func test_hasAccessToMenuItem_speakerUser_returnCorrectValueForEachMenuItem() {
        //Arrange
        let menuInteractorMock = MenuInteractorMock(role: MemberRoles.Speaker)
        let menuPresenter = MenuPresenter(interactor: menuInteractorMock, menuWireframe: MenuWireframe())
        
        //Act
        let resSection0Row0 = menuPresenter.hasAccessToMenuItem(0, row: 0)
        let resSection0Row1 = menuPresenter.hasAccessToMenuItem(0, row: 1)
        let resSection1Row0 = menuPresenter.hasAccessToMenuItem(1, row: 0)
        let resSection1Row1 = menuPresenter.hasAccessToMenuItem(1, row: 1)
        let resSection2Row0 = menuPresenter.hasAccessToMenuItem(2, row: 0)
        let resSection2Row1 = menuPresenter.hasAccessToMenuItem(2, row: 1)
        let resSection2Row2 = menuPresenter.hasAccessToMenuItem(2, row: 2)
        let resSection3Row0 = menuPresenter.hasAccessToMenuItem(3, row: 0)
        let resSection3Row1 = menuPresenter.hasAccessToMenuItem(3, row: 1)
        let resSection3Row2 = menuPresenter.hasAccessToMenuItem(3, row: 2)
        let resSection3Row3 = menuPresenter.hasAccessToMenuItem(3, row: 3)
        let resSection3Row4 = menuPresenter.hasAccessToMenuItem(3, row: 4)
        let resSection3Row5 = menuPresenter.hasAccessToMenuItem(3, row: 5)
        let resSection3Row6 = menuPresenter.hasAccessToMenuItem(3, row: 6)
        let resSection3Row7 = menuPresenter.hasAccessToMenuItem(3, row: 7)
        
        
        //Assert
        XCTAssertEqual(true, resSection0Row0)
        XCTAssertEqual(true, resSection0Row1)
        XCTAssertEqual(true, resSection1Row0)
        XCTAssertEqual(true, resSection1Row1)
        XCTAssertEqual(true, resSection2Row0)
        XCTAssertEqual(true, resSection2Row1)
        XCTAssertEqual(true, resSection2Row2)
        XCTAssertEqual(true, resSection3Row0)
        XCTAssertEqual(true, resSection3Row1)
        XCTAssertEqual(true, resSection3Row2)
        XCTAssertEqual(true, resSection3Row3)
        XCTAssertEqual(true, resSection3Row4)
        XCTAssertEqual(true, resSection3Row5)
        XCTAssertEqual(false, resSection3Row6)
        XCTAssertEqual(true, resSection3Row7)
    }
}
