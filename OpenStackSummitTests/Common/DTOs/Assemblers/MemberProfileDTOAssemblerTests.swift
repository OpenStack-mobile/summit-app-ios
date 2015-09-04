//
//  MemberProfileDTOAssembler.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/4/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XCTest
import OpenStackSummit
import RealmSwift

class MemberProfileDTOAssembler: XCTestCase {
    
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
    
    func test_createDTO_speakerMemberFull_returnsDTOWithCorrectData() {
        // Arrange
        let member = Member()
        member.firstName = "Enzo"
        member.lastName = "Francescoli"
        member.jobTitle = "Developer at River Plate"
        member.pictureUrl = "http://picture.com.ar"
        member.bio = "This is the bio"
        member.location = "Buenos Aires, Argentina"
        member.twitter = "@el_enzo"
        member.IRC = "irc"
        member.speakerRole = PresentationSpeaker()
        realm.write {
            self.realm.add(member)
        }

        let event = SummitEvent()
        event.title = "Test Title"
        event.eventDescription = "Test Description"
        event.start = NSDate(timeIntervalSince1970: NSTimeInterval(1441137600))
        event.end = NSDate(timeIntervalSince1970: NSTimeInterval(1441141200))
        event.presentation = Presentation()
        event.presentation?.speakers.append(member)
        
        let memberProfileDTOAssembler = MemberProfileDTOAssembler()
        
        // Act
        let memberProfileDTO = memberProfileDTOAssembler.createDTO(member)
        
        // Assert
        XCTAssertEqual(, memberProfileDTO.name)
    }
}
