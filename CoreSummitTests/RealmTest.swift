//
//  RealmTest.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/3/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import XCTest
import SwiftFoundation
import CoreSummit
import RealmSwift

final class RealmTest: XCTestCase {
    
    let realm = try! Realm()
    
    func testSummit() {
        
        // load test data
        let testJSON = loadJSON("AustinSummit")
        
        guard let summit = Summit(JSONValue: testJSON)
            else { XCTFail("Could not decode from JSON"); return }
        
        var realmSummit: RealmSummit!
            
        do { try realm.write { realmSummit = summit.save(realm) } }
            
        catch { XCTFail("\(error)"); return }
        
        let decodedSummit = Summit(realmEntity: realmSummit)
        
        var decodedDump = ""
        
        var summitDump = ""
        
        dump(decodedSummit, &decodedDump)
        
        dump(summit, &summitDump)
        
        XCTAssert(decodedDump == summitDump, "Original summit must equal decoded summit")
    }
}
