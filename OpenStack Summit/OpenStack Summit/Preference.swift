//
//  Preference.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 7/27/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation

struct Preference {
    
    // MARK: - Properties
    
    static var appBuild: Int {
        
        get { return object(for: .appBuild) as? Int ?? 0 }
        
        set { set(object: newValue, for: .appBuild) }
    }
    
    /*static var goingToSummit: Bool {
        
        get { return object(for: .goingToSummit) as? Bool ?? false }
        
        set { set(object: newValue, for: .goingToSummit) }
    }*/
    
    /// Last time user has offered to review the app.
    static var lastAppReview: Date? {
        
        get { return object(for: .lastAppReview) as? Date }
        
        set { set(object: newValue, for: .lastAppReview) }
    }
    
    // MARK: - Private Methods
    
    @inline(__always)
    static func object(for key: Key) -> Any? {
        
        return UserDefaults.standard.object(forKey: key.rawValue)
    }
    
    @inline(__always)
    static func set(object: Any?, for key: Key) {
        
        UserDefaults.standard.set(object, forKey: key.rawValue)
        
        UserDefaults.standard.synchronize()
    }
}

// MARK: - Keys

extension Preference {
    
    enum Key: String {
        
        case appBuild
        case goingToSummit
        case lastAppReview
    }
}
