//
//  FeedbackDTOAssemblerTests.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/16/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import XCTest
import OpenStackSummit

class FeedbackDTOAssemblerTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func test_createDTO_validFeedback_returnCorrectDTO() {
        // Arrange
        let feedbackDTOAssembler = FeedbackDTOAssembler()
        let feedback = Feedback()
        feedback.id = 1
        feedback.rate = 5
        feedback.review = "good event!"
        feedback.date = NSDate()
        feedback.event = SummitEvent()
        feedback.event.id = 2
        feedback.event.name = "Cisco Sponsor Session 1"
        feedback.owner = SummitAttendee()
        feedback.owner.firstName = "Enzo"
        feedback.owner.lastName = "Francescoli"
        
        // Act
        let feedbackDTO = feedbackDTOAssembler.createDTO(feedback)
        
        // Assert
        XCTAssertEqual(feedback.id, feedbackDTO.id)
        XCTAssertEqual(feedback.rate, feedbackDTO.rate)
        XCTAssertEqual(feedback.review, feedbackDTO.review)
        XCTAssertEqual(feedback.event.id, feedbackDTO.eventId)
        XCTAssertEqual(feedback.event.name, feedbackDTO.eventName)
        XCTAssertEqual(feedback.owner.firstName + " " + feedback.owner.lastName, feedbackDTO.owner)
        //TODO date
    }
}
