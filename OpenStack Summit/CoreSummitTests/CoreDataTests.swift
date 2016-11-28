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
            
            guard let summit = Summit(JSONValue: testJSON)
                else { XCTFail("Could not decode from JSON"); return }
            
            // decode
            var managedObject: SummitManagedObject!
            
            do { managedObject = try summit.save(managedObjectContext) }
                
            catch { XCTFail("\(error)"); return }
            
            let decodedSummit = Summit(managedObject: managedObject)
            
            XCTAssert(summit == decodedSummit, "Original summit \(summitID) must equal decoded summit")
        }
    }
}
