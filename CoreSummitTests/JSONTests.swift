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
        
        guard let decodable = Summit(JSONValue: testJSON)
            else { XCTFail("Could not decode from JSON"); return }
        
        dump(decodable)
    }
}

private func loadJSON(filename: String) -> JSON.Value {
    
    let testBundle = NSBundle(forClass: JSONTests.self)
    
    let resourcePath = testBundle.pathForResource(filename, ofType: "json", inDirectory: nil, forLocalization: nil)!
    
    let JSONString = try! String(contentsOfFile: resourcePath)
    
    return JSON.Value(string: JSONString)!
}