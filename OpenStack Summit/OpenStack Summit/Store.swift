//
//  Store.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/3/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData
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
    
    static let fileURL: URL = {
        
        let fileManager = FileManager.default
        
        // get cache folder
        
        #if os(iOS) || os(watchOS) || os(OSX)
        let cacheURL = try! fileManager.url(for: .cachesDirectory,
                                             in: .userDomainMask,
                                             appropriateFor: nil,
                                             create: false)
        
        #elseif os(tvOS)
            
        let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: AppGroup)!
            
        let cacheURL = containerURL
            .appendingPathComponent("Library", isDirectory: true)
            .appendingPathComponent("Caches", isDirectory: true)
            
        #endif
        
        // get app folder
        let bundleIdentifier = Bundle.main.bundleIdentifier!
        let folderURL = cacheURL.appendingPathComponent(bundleIdentifier, isDirectory: true)
        
        // create folder if doesnt exist
        var folderExists: ObjCBool = false
        if fileManager.fileExists(atPath: folderURL.path, isDirectory: &folderExists) == false
            || folderExists.boolValue == false {
            
            try! fileManager.createDirectory(at: folderURL, withIntermediateDirectories: true)
        }
        
        let fileURL = folderURL.appendingPathComponent("data.sqlite", isDirectory: false)
        
        return fileURL
    }()
    
    static func createPersistentStore(_ coordinator: NSPersistentStoreCoordinator) throws -> NSPersistentStore {
        
        func createStore() throws -> NSPersistentStore {
            
            return try coordinator.addPersistentStore(ofType: NSSQLiteStoreType,
                                                      configurationName: nil,
                                                      at: Store.fileURL,
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
    
    static func deletePersistentStore(_ store: (NSPersistentStoreCoordinator, NSPersistentStore)? = nil) throws {
        
        let url = self.fileURL
        
        if FileManager.default.fileExists(atPath: url.path) {
            
            // delete file
            try FileManager.default.removeItem(at: url)
        }
        
        if let (psc, persistentStore) = store {
            
            try psc.remove(persistentStore)
        }
    }
    
    #if os(watchOS)
    var cache: Summit? {
        
        get {
            
            if let summit = summitCache {
                
                return summit
                
            } else {
                
                guard let results = try? self.managedObjectContext.managedObjects(SummitManagedObject.self),
                    let managedObject = results.first
                    else { return nil }
                
                summitCache = Summit(managedObject: managedObject)
                
                return summitCache
            }
        }
        
        set {
            
            summitCache = newValue
        }
    }
    #endif
}

#if os(watchOS)
private var summitCache: Summit?
#endif
