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
    
    static let shared = Preferences.init()
    
    private let userDefaults: NSUserDefaults
    
    private init() {
        
        self.userDefaults = NSUserDefaults.standardUserDefaults()
    }
    
    // MARK: - Accessors
    
    private(set) var recentlyWatched: [Identifier] {
        
        get { return userDefaults.objectForKey(Key.recentlyWatched.rawValue) as? [Int] ?? [] }
        
        set { userDefaults.setObject(newValue, forKey: Key.recentlyWatched.rawValue) }
    }
    
    // MARK: - Methods
    
    func addRecentlyWatched(video: Identifier) {
        
        let limit = 10
        
        var recentlyWatched = self.recentlyWatched
        
        // insert at top
        if recentlyWatched.isEmpty {
            
            recentlyWatched.append(video)
            
        } else {
            
            recentlyWatched.insert(video, atIndex: 0)
        }
        
        // trim
        recentlyWatched = Array(recentlyWatched.prefix(limit))
        
        // store new value
        self.recentlyWatched = recentlyWatched
    }
    
    // MARK: - Private Methods
    
    private subscript (key: Key) -> AnyObject? {
        
        get { return userDefaults.objectForKey(key.rawValue) }
        
        set {
            
            userDefaults.setObject(newValue, forKey: key.rawValue)
            
            
        }
    }
}

// MARK: - Supporting Types

private extension Preferences {
    
    enum Key: String {
        
        case recentlyWatched
    }
}
