//
//  JSONTests.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import XCTest
import SwiftFoundation
@testable import CoreSummit

final class JSONTests: XCTestCase {

    func testSummit() {
        
        let testJSON = loadJSON("Summit")
        
        guard let _ = Summit(JSONValue: testJSON)
            else { XCTFail("Could not decode from JSON"); return }
    }
    
    func testAustinSummit() {
        
        let testJSON = loadJSON("AustinSummit")
        
        guard let summit = Summit(JSONValue: testJSON)
            else { XCTFail("Could not decode from JSON"); return }
        
        XCTAssert(summit.speakers.isEmpty == false, "No Speakers parsed")
    }
    
    func testDataUpdates1() {
        
        let testJSON = loadJSON("DataUpdates1")
        
        guard let jsonArray = testJSON.arrayValue,
            let dataUpdates = DataUpdate.fromJSON(jsonArray)
            else { XCTFail("Could not decode from JSON"); return }
        
        XCTAssert(dataUpdates.isEmpty == false, "No DataUpdate parsed")
        XCTAssert(dataUpdates.count == 42, "\(dataUpdates.count) DataUpdate. Should be 42")
    }
    
    func testDataUpdates2() {
        
        let testJSON = loadJSON("DataUpdates2")
        
        guard let jsonArray = testJSON.arrayValue,
            let dataUpdates = DataUpdate.fromJSON(jsonArray)
            else { XCTFail("Could not decode from JSON"); return }
        
        XCTAssert(dataUpdates.isEmpty == false, "No DataUpdate parsed")
        XCTAssert(dataUpdates.count == 1, "\(dataUpdates.count) DataUpdate. Should be 1")
        
        guard let dataUpdateEntity = dataUpdates.first?.entity,
            case let .JSON(entityJSON) = dataUpdateEntity,
            let _ = Event.DataUpdate(JSONValue: .Object(entityJSON))
            else { XCTFail("Could not decode from JSON"); return }
    }
    
    func testDataUpdates3() {
        
        let testJSON = loadJSON("DataUpdates3")
        
        let dataUpdatesCount = 67
        
        guard let jsonArray = testJSON.arrayValue,
            let dataUpdates = DataUpdate.fromJSON(jsonArray)
            else { XCTFail("Could not decode from JSON"); return }
        
        XCTAssert(dataUpdates.isEmpty == false, "No DataUpdate parsed")
        XCTAssert(dataUpdates.count == dataUpdatesCount, "\(dataUpdates.count) DataUpdate. Should be \(dataUpdatesCount)")
    }
    
    func testDataUpdates4() {
        
        let testJSON = loadJSON("DataUpdates4")
        
        guard let jsonArray = testJSON.arrayValue,
            let dataUpdates = DataUpdate.fromJSON(jsonArray)
            else { XCTFail("Could not decode from JSON"); return }
        
        guard let dataUpdateEntity = dataUpdates.first?.entity,
            case let .JSON(entityJSON) = dataUpdateEntity,
            let _ = SummitDataUpdate(JSONValue: .Object(entityJSON))
            else { XCTFail("Could not decode from JSON"); return }
    }
    
    func testDataUpdates5() {
        
        let testJSON = loadJSON("DataUpdates5")
        
        let dataUpdatesCount = 4
        
        guard let jsonArray = testJSON.arrayValue,
            let dataUpdates = DataUpdate.fromJSON(jsonArray)
            else { XCTFail("Could not decode from JSON"); return }
        
        XCTAssert(dataUpdates.isEmpty == false, "No DataUpdate parsed")
        XCTAssert(dataUpdates.count == dataUpdatesCount, "\(dataUpdates.count) DataUpdate. Should be \(dataUpdatesCount)")
        
        for dataUpdate in dataUpdates {
            
            guard dataUpdate.operation == .Update,
                let dataUpdateEntity = dataUpdate.entity,
                case let .JSON(entityJSON) = dataUpdateEntity,
                let type = dataUpdate.className.type,
                let _ = type.init(JSONValue: .Object(entityJSON))
                else { XCTFail("Could not decode \(dataUpdate.className) from JSON"); return }
        }
    }
    
    func testMember1() {
        
        let testJSON = loadJSON("Member1")
        
        guard let _ = Member(JSONValue: testJSON)
            else { XCTFail("Could not decode from JSON"); return }
    }
}
