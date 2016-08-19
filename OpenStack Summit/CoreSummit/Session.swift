//
//  Session.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 7/31/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

/// Provides the storage for session values
public protocol SessionStorage {
    
    /// The name of the authenticated user.
    var name: String? { get set }
    
    /// The authenticated member.
    var member: SessionMember?  { get set }
    
    /// Whether the device previously had a passcode.
    var hadPasscode: Bool { get set }
}

public extension SessionStorage {
    
    /// Resets the session storage.
    mutating func clear() {
        
        self.name = nil
        self.member = nil
    }
}

/// The type of member for the current session. 
public enum SessionMember {
    
    case attendee(Identifier)
    case nonConfirmedAttendee
}

// MARK: - Implementations

public final class UserDefaultsSessionStorage: SessionStorage {
    
    public let userDefaults: NSUserDefaults
    
    public init(userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()) {
        
        self.userDefaults = userDefaults
    }
    
    public var member: SessionMember? {
        
        get {
            
            guard let memberValue = userDefaults.stringForKey(Key.member.rawValue)
                else { return nil }
            
            guard memberValue != UserDefaultsSessionStorage.nonConfirmedAttendeeValue
                else { return .nonConfirmedAttendee }
            
            let identifier = Int(memberValue)!
            
            return .attendee(identifier)
        }
        
        set {
            
            guard let member = newValue
                else { userDefaults.removeObjectForKey(Key.member.rawValue); return }
            
            let stringValue: String
            
            switch member {
                
            case .nonConfirmedAttendee:
                
                stringValue = UserDefaultsSessionStorage.nonConfirmedAttendeeValue
                
            case let .attendee(memberID):
                
                stringValue = "\(memberID)"
            }
            
            userDefaults.setObject(stringValue as NSString, forKey: Key.member.rawValue)
            
            userDefaults.synchronize()
        }
    }
    
    public var name: String? {
        
        get { return userDefaults.stringForKey(Key.name.rawValue) }
        
        set {
            
            guard let stringValue = newValue
                else { userDefaults.removeObjectForKey(Key.name.rawValue); return }
            
            userDefaults.setObject(stringValue as NSString, forKey: Key.name.rawValue)
            
            userDefaults.synchronize()
        }
    }
    
    public var hadPasscode: Bool {
        
        get { return userDefaults.boolForKey(Key.hadPasscode.rawValue) }
        
        set { userDefaults.setBool(newValue, forKey: Key.hadPasscode.rawValue) }
    }
    
    private enum Key: String {
        
        case member = "CoreSummit.UserDefaultsSessionStorage.Key.Member"
        case name = "CoreSummit.UserDefaultsSessionStorage.Key.Name"
        case hadPasscode = "CoreSummit.UserDefaultsSessionStorage.Key.HadPasscode"
    }
    
    private static let nonConfirmedAttendeeValue = "CoreSummit.UserDefaultsSessionStorage.NonConfirmedAttendee"
}
