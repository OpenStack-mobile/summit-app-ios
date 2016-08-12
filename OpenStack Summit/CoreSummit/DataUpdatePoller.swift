//
//  DataUpdatePoller.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 8/10/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import SwiftFoundation

public final class DataUpdatePoller {
    
    public static let shared = DataUpdatePoller()
    
    // MARK: - Properties
    
    public var pollingInterval: Double = 30
    
    public var log: ((String) -> ())?
    
    public var storage: DataUpdatePollerStorage?
    
    // MARK: - Private Properties
    
    private var timer: NSTimer?
    
    // MARK: - Initializations
    
    deinit {
        
        stop()
    }
    
    // MARK: - Methods
    
    public func start() {
        
        timer?.invalidate()
        
        timer = NSTimer.scheduledTimerWithTimeInterval(pollingInterval, target: self, selector: #selector(DataUpdatePoller.pollServer), userInfo: nil, repeats: true)
        
        pollServer()
    }
    
    public func stop() {
        
        timer?.invalidate()
    }
    
    @objc private func pollServer() {
        
        // dont poll if not connectivity
        guard Reachability.connected else { return }
        
        // dont poll if no active summit
        guard let summit = Store.shared.realm.objects(RealmSummit.self).first else { return }
        
        log?("Polling server for data updates")
        
        /// Handles the polling of the data updates
        func process(response response: ErrorValue<[DataUpdate]>) {
            
            switch response {
                
            case let .Error(error):
                
                log?("Error polling server for data updates: \(error)")
                
                //Crashlytics.sharedInstance().recordError(error!)
                
            case let .Value(dataUpdates):
                
                for update in dataUpdates {
                    
                    guard Store.shared.process(update) else {
                        
                        // could not process update
                        
                        //Crashlytics.sharedInstance().recordError(friendlyError)
                        
                        return
                    }
                    
                    // store latest data update
                    storage?.latestDataUpdate = update.identifier
                }
                
                if dataUpdates.isEmpty == false {
                    
                    log?("Processed \(dataUpdates.count) data updates")
                }
            }
        }
        
        // execute request
        
        if let latestDataUpdate = storage?.latestDataUpdate {
            
            Store.shared.dataUpdates(latestDataUpdate: latestDataUpdate) { process(response: $0) }
            
        } else {
            
            Store.shared.dataUpdates(from: Date(foundation: summit.initialDataLoadDate)) { process(response: $0) }
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
    
    public let userDefaults: NSUserDefaults
    
    public init(userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()) {
        
        self.userDefaults = userDefaults
    }
    
    public var latestDataUpdate: Identifier? {
        
        get { return userDefaults.objectForKey(Key.LatestDataUpdate.rawValue) as? Int }
        
        set {
            
            guard let value = newValue
                else { userDefaults.removeObjectForKey(Key.LatestDataUpdate.rawValue); return }
            
            userDefaults.setObject(value, forKey: Key.LatestDataUpdate.rawValue)
        }
    }
    
    public enum Key: String {
        
        case LatestDataUpdate = "CoreSummit.UserDefaultsDataUpdatePollerStorage.Key.LatestDataUpdate"
    }
}


