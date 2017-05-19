//
//  Preference.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 7/27/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation

struct Preference {
    
    static var appBuild: Int {
        
        get { return UserDefaults.standard.integer(forKey: Key.appBuild.rawValue) }
        
        set { UserDefaults.standard.set(newValue, forKey: Key.appBuild.rawValue) }
    }
    
    static var goingToSummit: Bool {
        
        get { return UserDefaults.standard.bool(forKey: Key.goingToSummit.rawValue)}
        
        set { UserDefaults.standard.set(newValue, forKey: Key.goingToSummit.rawValue) }
    }
    
    /// Last time user has offered to review the app.
    static var lastAppReview: Date? {
        
        get { return (UserDefaults.standard.object(forKey: Key.lastAppReview.rawValue) as! NSDate?) as Date? }
        
        set { UserDefaults.standard.set(newValue, forKey: Key.lastAppReview.rawValue) }
    }
}

// MARK: - Keys

private extension Preference {
    
    enum Key: String {
        
        case appBuild
        case goingToSummit
        case lastAppReview
    }
}
