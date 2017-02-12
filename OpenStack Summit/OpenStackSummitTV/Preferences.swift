//
//  Preferences.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/11/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import typealias CoreSummit.Identifier

final class Preferences {
    
    static let shared = Preferences()
    
    private let userDefaults: NSUserDefaults
    
    private init() {
        
        self.userDefaults = NSUserDefaults(suiteName: AppGroup)!
    }
    
    // MARK: - Accessors
    
    private(set) var recentlyPlayed: [Identifier] {
        
        get { return self[.recentlyPlayed] as? [Int] ?? [] }
        
        set { self[.recentlyPlayed] = newValue as [NSNumber] }
    }
    
    // MARK: - Methods
    
    func addRecentlyPlayed(video: Identifier) {
        
        let limit = 10
        
        var recentlyPlayed = self.recentlyPlayed
        
        // remove previous instances
        var didRemovePrevious = false
        repeat {
            
            if let previousIndex = recentlyPlayed.indexOf(video) {
                
                recentlyPlayed.removeAtIndex(previousIndex)
                didRemovePrevious = true
                
            } else {
                
                didRemovePrevious = false
            }
            
        } while didRemovePrevious
        
        // insert at top
        if recentlyPlayed.isEmpty {
            
            recentlyPlayed.append(video)
            
        } else {
            
            recentlyPlayed.insert(video, atIndex: 0)
        }
        
        // trim
        recentlyPlayed = Array(recentlyPlayed.prefix(limit))
        
        // store new value
        self.recentlyPlayed = recentlyPlayed
    }
    
    // MARK: - Private Methods
    
    private subscript (key: Key) -> AnyObject? {
        
        get { return userDefaults.objectForKey(key.rawValue) }
        
        set {
            
            userDefaults.setObject(newValue, forKey: key.rawValue)
            userDefaults.synchronize()
        }
    }
}

// MARK: - Supporting Types

private extension Preferences {
    
    enum Key: String {
        
        case recentlyPlayed
    }
}
