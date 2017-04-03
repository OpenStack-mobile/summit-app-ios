//
//  PredicateTests.swift
//  PredicateTests
//
//  Created by Alsey Coleman Miller on 4/2/17.
//  Copyright © 2017 PureSwift. All rights reserved.
//

import XCTest
import Foundation
import struct SwiftFoundation.Date
import struct SwiftFoundation.Data
@testable import CoreSummit

final class PredicateTests: XCTestCase {
    
    class Person: NSObject {
        var id: Int
        var name: String
        init(id: Int, name: String) {
            self.id = id
            self.name = name
            super.init()
        }
    }
    
    class Event: NSObject {
        var id: Int
        var name: String
        var start: NSDate
        var speakers: Set<Person>
        init(id: Int, name: String, start: NSDate, speakers: Set<Person>) {
            self.id = id
            self.name = name
            self.start = start
            self.speakers = speakers
            super.init()
        }
    }
    
    func testPredicate1() {
        
        let predicate: Predicate = "id" > Int64(0)
            &&& "id" != Int64(99)
            &&& "name".compare(.beginsWith, .value(.string("C")))
            &&& "name".compare(.contains, [.diacriticInsensitive, .caseInsensitive], .value(.string("COLE")))
        
        let nsPredicate = predicate.toFoundation()
        
        print(predicate)
        print(nsPredicate)
        
        XCTAssert(predicate.description == nsPredicate.description, "Invalid description")
        XCTAssert(nsPredicate.evaluateWithObject(Person(id: 1, name: "Coléman")))
    }
    
    func testPredicate2() {
        
        let identifiers: [Int64] = [1, 2, 3]
        
        let predicate: Predicate = "name".any(in: ["coleman", "miller"])
            &&& "id".any(in: identifiers)
            ||| "id".all(in: [Int16]())
        
        let nsPredicate = predicate.toFoundation()
        
        print(predicate)
        print(nsPredicate)
        
        XCTAssert(predicate.description == nsPredicate.description, "Invalid description")
        let test = [Person(id: 1, name: "coleman"), Person(id: 2, name: "miller")]
        XCTAssert(nsPredicate.evaluateWithObject(test))
    }
    
    func testPredicate3() {
        
        let identifiers: [Int64] = [1, 2, 3]
        
        let predicate: Predicate = "name".`in`(["coleman", "miller"])
            &&& "id".`in`(identifiers)
        
        let nsPredicate = predicate.toFoundation()
        
        print(predicate)
        print(nsPredicate)
        
        XCTAssert(predicate.description == nsPredicate.description, "Invalid description")
        XCTAssert(nsPredicate.evaluateWithObject(Person(id: 1, name: "coleman")))
        XCTAssert(([Person(id: 1, name: "coleman"), Person(id: 2, name: "miller")] as NSArray).filteredArrayUsingPredicate(nsPredicate).count == 2)
    }
    
    func testPredicate4() {
        
        let events = [Event(id: 100, name: "Awesome Event", start: NSDate(timeIntervalSince1970: 0.0), speakers: [Person(id: 1, name: "Alsey Coleman Miller")])]
        
        let now = Date()
        
        let identifiers: [Int64] = [100, 200, 300]
        
        let predicate: Predicate = "name".compare(.contains, [.caseInsensitive], .value(.string("event")))
            &&& "name".`in`(["Awesome Event"])
            &&& "id".`in`(identifiers)
            &&& "start" < now
            &&& "speakers.name".all(in: ["Alsey Coleman Miller"])
        
        let nsPredicate = predicate.toFoundation()
        
        print(predicate)
        print(nsPredicate)
        
        XCTAssert(nsPredicate.evaluateWithObject(events[0]))
        XCTAssert((events as NSArray).filteredArrayUsingPredicate(nsPredicate).count == events.count)
    }
}
