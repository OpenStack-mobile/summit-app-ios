//
//  Session.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 7/31/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

/// Provides the storage for session values
public protocol SessionStorage {
    
    /// The authenticated member.
    var member: Identifier?  { get set }
    
    /// Whether the device previously had a passcode.
    var hadPasscode: Bool { get set }
}

public extension SessionStorage {
    
    /// Resets the session storage.
    mutating func clear() {
        
        self.member = nil
    }
}

// MARK: - Implementations

public final class UserDefaultsSessionStorage: SessionStorage {
    
    public let userDefaults: NSUserDefaults
    
    public init(userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()) {
        
        self.userDefaults = userDefaults
    }
    
    public var member: Identifier? {
        
        get { return (userDefaults.objectForKey(Key.member.rawValue) as? NSNumber)?.integerValue }
        
        set {
            
            guard let member = newValue
                else { userDefaults.removeObjectForKey(Key.member.rawValue); return }
            
            userDefaults.setObject(NSNumber(long: member), forKey: Key.member.rawValue)
            
            userDefaults.synchronize()
        }
    }
    
    public var hadPasscode: Bool {
        
        get { return userDefaults.boolForKey(Key.hadPasscode.rawValue) }
        
        set { userDefaults.setBool(newValue, forKey: Key.hadPasscode.rawValue) }
    }
    
    private enum Key: String {
        
        case member = "CoreSummit.UserDefaultsSessionStorage.Key.Member"
        case hadPasscode = "CoreSummit.UserDefaultsSessionStorage.Key.HadPasscode"
    }
}
