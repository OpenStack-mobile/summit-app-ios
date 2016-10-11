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
    
    func createRealm(name: String) -> Realm {
        
        Realm.Configuration.defaultConfiguration.inMemoryIdentifier = name
        
        return try! Realm()
    }
    
    func testSummits() {
        
        for summitID in SummitJSONIdentifiers {
            
            let realm = createRealm("RealmTests_Summit\(summitID)")
            
            // load test data
            let testJSON = loadJSON("Summit\(summitID)")
            
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
            
            let decodedDump = dump(decodedSummit, "DecodedSummit\(summitID)Dump.txt")
            let summitDump = dump(summit, "Summit\(summitID)Dump.txt")
            
            XCTAssert(decodedDump == summitDump, "Original summit \(summitID) must equal decoded summit")
        }
    }
}
