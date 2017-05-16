//
//  TestUtilities.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/3/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData
import JSON
@testable import CoreSummit

internal func loadJSON(_ filename: String) -> JSON.Value {
    
    let testBundle = Bundle(for: JSONTests.self)
    
    let resourcePath = testBundle.path(forResource: filename, ofType: "json", inDirectory: nil, forLocalization: nil)!
    
    let JSONString = try! String(contentsOfFile: resourcePath)
    
    return try! JSON.Value(string: JSONString)
}

@discardableResult
internal func dump(_ dumpable: Any, _ outputFileName: String) -> String {
    
    var dumpString = ""
    
    dump(dumpable, to: &dumpString)
    
    let stringData = dumpString.toUTF8Data()
    
    try? stringData.write(to: Foundation.URL(fileURLWithPath: outputDirectory + outputFileName), options: [.atomic])
    
    return dumpString
}

let outputDirectory: String = {
    
    let outputDirectory = NSTemporaryDirectory() + "CoreSummitTests" + "/"
    
    var isDirectory: ObjCBool = false
    
    if Foundation.FileManager.default.fileExists(atPath: outputDirectory, isDirectory: &isDirectory) == false {
        
        try! Foundation.FileManager.default.createDirectory(atPath: outputDirectory, withIntermediateDirectories: false, attributes: nil)
    }
    
    print("Test output directory: \(outputDirectory)")
    
    return outputDirectory
}()

func createStore() throws -> Store {
    
    return try Store(environment: .staging,
                     session: UserDefaultsSessionStorage(),
                     createPersistentStore: {
                        try $0.addPersistentStore(ofType: NSInMemoryStoreType,
                            configurationName: nil,
                            at: nil,
                            options: nil) },
                     deletePersistentStore: { _ in fatalError("Not needed") })
}
