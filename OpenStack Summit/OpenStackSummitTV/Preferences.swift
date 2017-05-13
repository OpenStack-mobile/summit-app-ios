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
    
    private let userDefaults: UserDefaults
    
    private init() {
        
        self.userDefaults = UserDefaults(suiteName: AppGroup)!
    }
    
    // MARK: - Accessors
    
    private(set) var recentlyPlayed: [Identifier] {
        
        get { return self[.recentlyPlayed] as! [Identifier]? ?? [] }
        
        set { self[.recentlyPlayed] = newValue }
    }
    
    // MARK: - Methods
    
    func addRecentlyPlayed(_ video: Identifier) {
        
        let limit = 10
        
        var recentlyPlayed = self.recentlyPlayed
        
        // remove previous instances
        var didRemovePrevious = false
        repeat {
            
            if let previousIndex = recentlyPlayed.index(of: video) {
                
                recentlyPlayed.remove(at: previousIndex)
                didRemovePrevious = true
                
            } else {
                
                didRemovePrevious = false
            }
            
        } while didRemovePrevious
        
        // insert at top
        if recentlyPlayed.isEmpty {
            
            recentlyPlayed.append(video)
            
        } else {
            
            recentlyPlayed.insert(video, at: 0)
        }
        
        // trim
        recentlyPlayed = Array(recentlyPlayed.prefix(limit))
        
        // store new value
        self.recentlyPlayed = recentlyPlayed
    }
    
    // MARK: - Private Methods
    
    private subscript (key: Key) -> Any? {
        
        get { return userDefaults.object(forKey: key.rawValue) as Any? }
        
        set {
            
            userDefaults.set(newValue, forKey: key.rawValue)
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
