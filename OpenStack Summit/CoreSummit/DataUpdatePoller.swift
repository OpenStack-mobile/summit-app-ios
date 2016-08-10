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
    
    // MARK: - Methods
    
    public func start() {
        
        guard timer == nil else { return }
        
        timer = NSTimer.scheduledTimerWithTimeInterval(pollingInterval, target: self, selector: #selector(DataUpdatePoller.pollServer), userInfo: nil, repeats: true)
        
        pollServer()
    }
    
    @objc private func pollServer() {
        
        guard Reachability.connected else { return }
        
        log?("Polling server for data updates")
        
        
    }
}

// MARK: - Supporting Types

public protocol DataUpdatePollerStorage {
    
    var fromDate: Date { get }
}
