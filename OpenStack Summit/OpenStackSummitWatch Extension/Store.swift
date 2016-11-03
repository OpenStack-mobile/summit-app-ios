//
//  Store.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/3/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData
import SwiftFoundation
import CoreSummit

extension Store {
    
    static var shared: Store {
        
        struct Static {
            static let store = try! Store(environment: AppEnvironment,
                                     session: UserDefaultsSessionStorage(),
                                     createPersistentStore: Store.createPersistentStore,
                                     deletePersistentStore: Store.deletePersistentStore)
        }
        
        return Static.store
    }
    
    static let fileURL: NSURL = {
        
        let cacheURL = try! NSFileManager.defaultManager().URLForDirectory(NSSearchPathDirectory.CachesDirectory,
                                                                           inDomain: NSSearchPathDomainMask.UserDomainMask,
                                                                           appropriateForURL: nil,
                                                                           create: false)
        
        let fileURL = cacheURL.URLByAppendingPathComponent("data.sqlite")
        
        return fileURL
    }()
    
    static func createPersistentStore(coordinator: NSPersistentStoreCoordinator) throws -> NSPersistentStore {
        
        return try coordinator.addPersistentStoreWithType(NSSQLiteStoreType,
                                                          configuration: nil,
                                                          URL: Store.fileURL,
                                                          options: nil)
    }
    
    static func deletePersistentStore(store: (NSPersistentStoreCoordinator, NSPersistentStore)? = nil) throws {
        
        let url = self.fileURL
        
        if NSFileManager.defaultManager().fileExistsAtPath(url.path!) {
            
            // delete file
            try NSFileManager.defaultManager().removeItemAtURL(url)
        }
        
        if let (psc, persistentStore) = store {
            
            try psc.removePersistentStore(persistentStore)
        }
    }
    
}
