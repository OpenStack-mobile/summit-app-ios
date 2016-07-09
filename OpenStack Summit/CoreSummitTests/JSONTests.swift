//
//  JSONTests.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import XCTest
import SwiftFoundation
import CoreSummit

final class JSONTests: XCTestCase {

    func testSummit() {
        
        let testJSON = loadJSON("Summit")
        
        guard let _ = Summit(JSONValue: testJSON)
            else { XCTFail("Could not decode from JSON"); return }
        
        //dump(decodable)
    }
    
    func testAustinSummit() {
        
        let testJSON = loadJSON("AustinSummit")
        
        guard let summit = Summit(JSONValue: testJSON)
            else { XCTFail("Could not decode from JSON"); return }
        
        XCTAssert(summit.speakers.isEmpty == false, "No Speakers parsed")
        
        //dump(decodable) // too large
    }
}