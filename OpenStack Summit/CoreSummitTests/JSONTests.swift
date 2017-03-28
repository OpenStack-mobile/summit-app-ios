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

let SummitJSONIdentifiers = [6, 7, 22]

let MemberJSONIdentifiers = 1 ... 3

final class JSONTests: XCTestCase {
    
    func testSummits() {
        
        for summitID in SummitJSONIdentifiers {
            
            let testJSON = loadJSON("Summit\(summitID)")
            
            guard let summit = Summit(JSONValue: testJSON)
                else { XCTFail("Could not decode from JSON"); return }
            
            XCTAssert(summit.schedule.isEmpty == false, "No Events")
            XCTAssert(summit.speakers.isEmpty == false, "No Speakers")
        }
    }
    
    func testMembers() {
        
        for memberJSONID in MemberJSONIdentifiers {
            
            let testJSON = loadJSON("Member\(memberJSONID)")
            
            guard let _ = MemberResponse.Member(JSONValue: testJSON)
                else { XCTFail("Could not decode from JSON"); return }
        }
    }
    
    func testAllSummits() {
        
        let testJSON = loadJSON("AllSummits")
        
        guard let reponse = SummitsResponse(JSONValue: testJSON)
            else { XCTFail("Could not decode from JSON"); return }
        
        XCTAssert(reponse.page.items.isEmpty == false, "No summits parsed")
    }
    
    func testListMembers() {
        
        let testJSON = loadJSON("ListMembers")
        
        guard let page = Page<Member>(JSONValue: testJSON)
            else { XCTFail("Could not decode from JSON"); return }
        
        XCTAssert(page.items.isEmpty == false, "No members parsed")
    }
    
    func testFeedback() {
        
        let testJSON = loadJSON("Feedback")
        
        guard let page = Page<Feedback>(JSONValue: testJSON)
            else { XCTFail("Could not decode from JSON"); return }
        
        XCTAssert(page.items.isEmpty == false, "No feedback parsed")
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
            let _ = EventDataUpdate(JSONValue: .Object(entityJSON))
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
    
    func testDataUpdates6() {
        
        let testJSON = loadJSON("DataUpdates6")
        
        guard let jsonArray = testJSON.arrayValue,
            let dataUpdates = DataUpdate.fromJSON(jsonArray)
            else { XCTFail("Could not decode from JSON"); return }
        
        XCTAssert(dataUpdates.isEmpty == false, "No DataUpdate parsed")
        XCTAssert(dataUpdates.count == 1, "\(dataUpdates.count) DataUpdate. Should be 1")
        
        guard let dataUpdateEntity = dataUpdates.first?.entity,
            case let .JSON(entityJSON) = dataUpdateEntity,
            let _ = VenueRoomDataUpdate(JSONValue: .Object(entityJSON))
            else { XCTFail("Could not decode from JSON"); return }
    }
    
    func testDataUpdates7() {
        
        let testJSON = loadJSON("DataUpdates7")
        
        guard let jsonArray = testJSON.arrayValue,
            let dataUpdates = DataUpdate.fromJSON(jsonArray)
            else { XCTFail("Could not decode from JSON"); return }
        
        XCTAssert(dataUpdates.isEmpty == false, "No DataUpdate parsed")
        XCTAssert(dataUpdates.count == 39, "\(dataUpdates.count) DataUpdate. Should be 39")
        
        for dataUpdate in dataUpdates {
            
            guard let dataUpdateEntity = dataUpdate.entity,
                case let .JSON(entityJSON) = dataUpdateEntity
                where dataUpdate.className == .MySchedule
                else { continue }
            
            guard let _ = EventDataUpdate(JSONValue: .Object(entityJSON))
                else { XCTFail("Could not decode from JSON"); return }
        }
    }
    
    func testDataUpdates8() {
        
        let testJSON = loadJSON("DataUpdates8")
        
        guard let jsonArray = testJSON.arrayValue,
            let dataUpdates = DataUpdate.fromJSON(jsonArray)
            else { XCTFail("Could not decode from JSON"); return }
        
        XCTAssert(dataUpdates.isEmpty == false, "No DataUpdate parsed")
        XCTAssert(dataUpdates.count == 1, "\(dataUpdates.count) DataUpdates. Should be 1")
        
        guard let dataUpdateEntity = dataUpdates.first?.entity,
            case let .JSON(entityJSON) = dataUpdateEntity,
            let _ = GroupEventDataUpdate(JSONValue: .Object(entityJSON))
            else { XCTFail("Could not decode from JSON"); return }
    }
    
    func testDataUpdates9() {
        
        let testJSON = loadJSON("DataUpdates9")
        
        guard let jsonArray = testJSON.arrayValue,
            let dataUpdates = DataUpdate.fromJSON(jsonArray)
            else { XCTFail("Could not decode from JSON"); return }
        
        XCTAssert(dataUpdates.isEmpty == false, "No DataUpdate parsed")
        XCTAssert(dataUpdates.count == 2, "\(dataUpdates.count) DataUpdate. Should be 2")
        
        for dataUpdate in dataUpdates {
            
            guard let dataUpdateEntity = dataUpdate.entity,
                case let .JSON(entityJSON) = dataUpdateEntity
                where dataUpdate.className == .SummitWIFIConnection
                else { continue }
            
            guard let _ = WirelessNetwork(JSONValue: .Object(entityJSON))
                else { XCTFail("Could not decode from JSON"); return }
        }
    }
    
    func testDataUpdates10() {
        
        let testJSON = loadJSON("DataUpdates10")
        
        guard let dataUpdate = DataUpdate(JSONValue: testJSON)
            else { XCTFail("Could not decode from JSON"); return }
        
        guard let dataUpdateEntity = dataUpdate.entity,
            case let .JSON(entityJSON) = dataUpdateEntity
            where dataUpdate.className == .MyFavorite
            else { XCTFail("Could not decode from JSON"); return }
        
        guard let _ = EventDataUpdate(JSONValue: .Object(entityJSON))
            else { XCTFail("Could not decode from JSON"); return }
    }
    
    func testDataUpdates11() {
        
        let testJSON = loadJSON("DataUpdates11")
        
        guard let dataUpdate = DataUpdate(JSONValue: testJSON),
            let dataUpdateEntity = dataUpdate.entity,
            case let .JSON(entityJSON) = dataUpdateEntity,
            let _ = Venue(JSONValue: .Object(entityJSON))
            else { XCTFail("Could not decode from JSON"); return }
    }
    
    func testDataUpdates12() {
        
        let testJSON = loadJSON("DataUpdates12")
        
        guard let dataUpdate = DataUpdate(JSONValue: testJSON),
            let dataUpdateEntity = dataUpdate.entity,
            case let .JSON(entityJSON) = dataUpdateEntity,
            let _ = TrackGroupDataUpdate(JSONValue: .Object(entityJSON))
            else { XCTFail("Could not decode from JSON"); return }
    }
}
