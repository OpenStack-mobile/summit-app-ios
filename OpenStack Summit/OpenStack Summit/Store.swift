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
        
        let store = Static.store
        
        if store.authenticatedMember == nil && store.session.member != nil {
            
            store.session.clear()
        }
        
        return store
    }
    
    static let fileURL: NSURL = {
        
        let cacheURL = try! NSFileManager.defaultManager().URLForDirectory(NSSearchPathDirectory.CachesDirectory,
                                                                           inDomain: NSSearchPathDomainMask.UserDomainMask,
                                                                           appropriateForURL: nil,
                                                                           create: false)
        
        let fileURL = cacheURL.URLByAppendingPathComponent("data.sqlite")!
        
        return fileURL
    }()
    
    static func createPersistentStore(coordinator: NSPersistentStoreCoordinator) throws -> NSPersistentStore {
        
        func createStore() throws -> NSPersistentStore {
            
            return try coordinator.addPersistentStoreWithType(NSSQLiteStoreType,
                                                              configuration: nil,
                                                              URL: Store.fileURL,
                                                              options: nil)
        }
        
        var store: NSPersistentStore!
        
        do { store = try createStore() }
        
        catch {
            
            // delete file
            try Store.deletePersistentStore()
            
            // try again
            store = try createStore()
        }
        
        return store
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
    
    #if os(watchOS)
    var cache: Summit? {
        
        struct Static {
            static var summit: Summit?
        }
        
        if let summit = Static.summit {
            
            return summit
            
        } else {
            
            guard let results = try? self.managedObjectContext.managedObjects(SummitManagedObject.self),
                let managedObject = results.first
                else { return nil }
            
            Static.summit = Summit(managedObject: managedObject)
            
            return Static.summit
        }
    }
    #endif
}

