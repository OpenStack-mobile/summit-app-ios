//
//  DataUpdatePoller.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 8/10/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public final class DataUpdatePoller {
    
    // MARK: - Properties
    
    public var polling = false
    
    public var pollingInterval: Double = 60
    
    public var log: ((String) -> ())?
    
    public let store: Store
    
    public var storage: DataUpdatePollerStorage
    
    public var summit: Identifier?
    
    // MARK: - Private Properties
    
    private var timer: Timer?
    
    // MARK: - Initialization
    
    deinit {
        
        stop()
    }
    
    public init(storage: DataUpdatePollerStorage, store: Store) {
        
        self.storage = storage
        self.store = store
    }
    
    // MARK: - Methods
    
    public func start() {
        
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(timeInterval: pollingInterval, target: self, selector: #selector(DataUpdatePoller.pollServer), userInfo: nil, repeats: true)
        
        pollServer()
    }
    
    public func stop() {
        
        timer?.invalidate()
    }
    
    @objc private func pollServer() {
        
        // dont poll if not connectivity
        #if os(iOS) || os(tvOS) || os(OSX)
        guard Reachability.connected else { return }
        #endif
        
        // dont poll if already polling
        guard !polling else { return }
        
        // dont poll if no active summit
        guard let summitID = self.summit,
            let summit = try! SummitManagedObject.find(summitID, context: store.managedObjectContext)
            else { return }
        
        print("Polling server for data updates for summit \(summitID)")
        
        /// Handles the polling of the data updates
        func process(response: ErrorValue<[DataUpdate]>) {
            
            switch response {
                
            case let .error(error):
                
                let nsError = (error as NSError)
                
                log?("Error polling server: \(nsError.code) - \(nsError.localizedDescription)")
                                
            case let .value(dataUpdates):
                
                var processedCount = 0
                
                for index in 0..<dataUpdates.count {
                    
                    let update = dataUpdates[index]
                    
                    let result = store.process(dataUpdate: update, summit: summit.id)
                    
                    if case let .success(value) = result {
                        
                        if !value {
                            
                            // could not process update
                            
                            log?("Could not process: \(update.identifier)")
                            
                            #if DEBUG
                            return // block
                            #endif
                        }
                        
                        // store latest data update
                        storage.latestDataUpdate = update.identifier
                        
                        processedCount = index
                    }
                    
                    // clear data pooler storage and exit loop if data wiping
                    if case .dataWipe = result {
                        
                        print("Data wiping")
                        
                        storage.clear()
                        
                        break
                    }
                }
                
                if dataUpdates.isEmpty == false {
                    
                    let context = store.privateQueueManagedObjectContext
                    
                    try! context.performErrorBlockAndWait { try context.validateAndSave() }
                    
                    if processedCount > 0 { print("Processed \(processedCount + 1) data updates") }
                }
            }
            
            polling = false
        }
        
        // execute request
        
        polling = true
        
        if let latestDataUpdate = storage.latestDataUpdate {
            
            store.dataUpdates(summit.id, latestDataUpdate: latestDataUpdate) { process(response: $0) }
            
        } else {
            
            store.dataUpdates(summit.id, from: summit.initialDataLoad ?? Date()) { process(response: $0) }
        }
    }
}

// MARK: - Supporting Types

public protocol DataUpdatePollerStorage {
    
    var latestDataUpdate: Identifier? { get set }
    
    mutating func clear()
}

public extension DataUpdatePollerStorage {
    
    mutating func clear() {
        
        self.latestDataUpdate = nil
    }
}

public final class UserDefaultsDataUpdatePollerStorage: DataUpdatePollerStorage {
    
    public let userDefaults: UserDefaults
    
    public init(userDefaults: UserDefaults = UserDefaults.standard) {
        
        self.userDefaults = userDefaults
    }
    
    public var latestDataUpdate: Identifier? {
        
        get { return userDefaults.object(forKey: Key.LatestDataUpdate.rawValue) as? Identifier }
        
        set {
            
            guard let value = newValue
                else { userDefaults.removeObject(forKey: Key.LatestDataUpdate.rawValue); return }
            
            userDefaults.set(value, forKey: Key.LatestDataUpdate.rawValue)
        }
    }
    
    public enum Key: String {
        
        case LatestDataUpdate = "CoreSummit.UserDefaultsDataUpdatePollerStorage.Key.LatestDataUpdate"
    }
}
