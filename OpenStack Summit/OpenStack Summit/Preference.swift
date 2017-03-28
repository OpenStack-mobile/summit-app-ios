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
        
        get { return NSUserDefaults.standardUserDefaults().integerForKey(Key.appBuild.rawValue) }
        
        set { NSUserDefaults.standardUserDefaults().setInteger(newValue, forKey: Key.appBuild.rawValue) }
    }
    
    static var goingToSummit: Bool {
        
        get { return NSUserDefaults.standardUserDefaults().boolForKey(Key.goingToSummit.rawValue)}
        
        set { NSUserDefaults.standardUserDefaults().setBool(newValue, forKey: Key.goingToSummit.rawValue) }
    }
}

// MARK: - Keys

private extension Preference {
    
    enum Key: String {
        
        case appBuild
        case goingToSummit
    }
}
