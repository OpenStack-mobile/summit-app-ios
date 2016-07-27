//
//  Preference.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 7/27/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation

struct Preference {
    
    static var appBuild: Int? {
        
        get { return NSUserDefaults.standardUserDefaults().integerForKey(Key.appBuild.rawValue) }
        
        set {
            guard let appBuild = newValue
                else { NSUserDefaults.standardUserDefaults().removeObjectForKey(Key.appBuild.rawValue); return }
            
            NSUserDefaults.standardUserDefaults().setInteger(appBuild, forKey: Key.appBuild.rawValue)
        }
    }
}

// MARK: - Keys

private extension Preference {
    
    enum Key: String {
        
        case appBuild
    }
}