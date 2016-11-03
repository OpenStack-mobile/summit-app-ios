//
//  CoreDataTests.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 11/3/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import XCTest
import Foundation
import CoreData
import SwiftFoundation
@testable import CoreSummit

final class CoreDataTests: XCTestCase {
    
    func testSummits() {
        
        for summitID in SummitJSONIdentifiers {
            
            let managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
            managedObjectContext.undoManager = nil
            managedObjectContext.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: NSManagedObjectModel.summitModel)
            try! managedObjectContext.persistentStoreCoordinator!.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
                        
            // load test data
            let testJSON = loadJSON("Summit\(summitID)")
            
            guard var summit = Summit(JSONValue: testJSON)
                else { XCTFail("Could not decode from JSON"); return }
            
            // decode
            var managedObject: SummitManagedObject!
            
            do { managedObject = try summit.save(managedObjectContext) }
                
            catch { XCTFail("\(error)"); return }
            
            var decodedSummit = Summit(managedObject: managedObject)
            
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
