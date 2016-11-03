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
            
            // sort relationhips so that they dump the same string
            summit.sortInPlace()
            decodedSummit.sortInPlace()
            
            // dump
            let decodedDump = dump(decodedSummit, "DecodedSummit\(summitID)Dump.txt")
            let summitDump = dump(summit, "Summit\(summitID)Dump.txt")
            
            XCTAssert(decodedDump == summitDump, "Original summit \(summitID) must equal decoded summit")
        }
    }
}

private extension Summit {
    
    /// Sorting method to produce and text for dump
    mutating func sortInPlace() {
        
        sponsors.sortInPlace { $0.identifier < $1.identifier }
        speakers.sortInPlace { $0.identifier < $1.identifier }
        summitTypes.sortInPlace { $0.identifier < $1.identifier }
        ticketTypes.sortInPlace { $0.identifier < $1.identifier }
        tracks.sortInPlace { $0.identifier < $1.identifier }
        trackGroups.sortInPlace { $0.identifier < $1.identifier }
        eventTypes.sortInPlace { $0.identifier < $1.identifier }
        locations.sortInPlace { $0.identifier < $1.identifier }
        schedule.sortInPlace { $0.identifier < $1.identifier }
        locations.sortInPlace { $0.identifier < $1.identifier }
        locations = locations.map {
            
            switch $0 {
                
            case var .venue(venue):
                
                venue.images.sortInPlace { $0.identifier < $1.identifier }
                venue.maps.sortInPlace { $0.identifier < $1.identifier }
                
                return .venue(venue)
                
            case var .room(room):
                
                return .room(room)
            }
        }
    }
}
