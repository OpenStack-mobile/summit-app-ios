//
//  TestUtilities.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/3/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData
import SwiftFoundation
@testable import CoreSummit

internal func loadJSON(filename: String) -> JSON.Value {
    
    let testBundle = NSBundle(forClass: JSONTests.self)
    
    let resourcePath = testBundle.pathForResource(filename, ofType: "json", inDirectory: nil, forLocalization: nil)!
    
    let JSONString = try! String(contentsOfFile: resourcePath)
    
    return JSON.Value(string: JSONString)!
}

internal func dump(dumpable: Any, _ outputFileName: String) -> String {
    
    var dumpString = ""
    
    dump(dumpable, &dumpString)
    
    let stringData = dumpString.toUTF8Data().toFoundation()
    
    stringData.writeToFile(outputDirectory + outputFileName, atomically: true)
    
    return dumpString
}

let outputDirectory: String = {
    
    let outputDirectory = NSTemporaryDirectory() + "CoreSummitTests" + "/"
    
    var isDirectory: ObjCBool = false
    
    if NSFileManager.defaultManager().fileExistsAtPath(outputDirectory, isDirectory: &isDirectory) == false {
        
        try! NSFileManager.defaultManager().createDirectoryAtPath(outputDirectory, withIntermediateDirectories: false, attributes: nil)
    }
    
    print("Test output directory: \(outputDirectory)")
    
    return outputDirectory
}()

func createStore() throws -> Store {
    
    return try Store(environment: .Staging,
                     session: UserDefaultsSessionStorage(),
                     createPersistentStore: {
                        try $0.addPersistentStoreWithType(NSInMemoryStoreType,
                            configuration: nil,
                            URL: nil,
                            options: nil) },
                     deletePersistentStore: { _ in fatalError("Not needed") })
}
