//
//  ModelTests.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 5/5/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import XCTest
@testable import CoreSummit

final class ModelTests: XCTestCase {

    func testNotificationTopicParse() {
        
        // Valid strings
        XCTAssert(Notification.Topic(rawValue: "/topics/ios_everyone") == Notification.Topic.everyone)
        XCTAssert(Notification.Topic(rawValue: "/topics/everyone") == Notification.Topic.everyone)
        XCTAssert(Notification.Topic(rawValue: "/topics/ios_member_1") == Notification.Topic.member(1))
        XCTAssert(Notification.Topic(rawValue: "/topics/member_1") == Notification.Topic.member(1))
        
        // Invalid Strings
        XCTAssert(Notification.Topic(rawValue: "/topics/ios_") == nil)
        XCTAssert(Notification.Topic(rawValue: "/topics/") == nil)
        XCTAssert(Notification.Topic(rawValue: "/topics") == nil)
        XCTAssert(Notification.Topic(rawValue: "/topics/fakeTopic") == nil)
        XCTAssert(Notification.Topic(rawValue: "/topics/ios_fakeTopic") == nil)
        XCTAssert(Notification.Topic(rawValue: "/topics/ios_member_") == nil)
        XCTAssert(Notification.Topic(rawValue: "/topics/ios_member_a") == nil)
        XCTAssert(Notification.Topic(rawValue: "/topics/ios_member") == nil)
    }
}
