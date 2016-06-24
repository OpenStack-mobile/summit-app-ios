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

final class RealmTests: XCTestCase {
    
    func createRealm() -> Realm {
        
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = "Test Realm"
        
        return try! Realm()
    }
    
    func testSummit() {
        
        let realm = createRealm()
        
        // load test data
        let testJSON = loadJSON("AustinSummit")
        
        guard var summit = Summit(JSONValue: testJSON)
            else { XCTFail("Could not decode from JSON"); return }
        
        // decode
        var realmSummit: RealmSummit!
            
        do { try realm.write { realmSummit = summit.save(realm) } }
            
        catch { XCTFail("\(error)"); return }
        
        var decodedSummit = Summit(realmEntity: realmSummit)
        
        // sort decoded locations so that they dump the same string
        summit.locations.sortInPlace { $0.rawValue.identifier < $1.rawValue.identifier }
        decodedSummit.locations.sortInPlace { $0.rawValue.identifier < $1.rawValue.identifier }
        
        // dump
        
        let decodedDump = dump(decodedSummit, "DecodedSummitDump.txt")
        let summitDump = dump(summit, "SummitDump.txt")
        
        XCTAssert(decodedDump == summitDump, "Original summit must equal decoded summit")
    }
}
