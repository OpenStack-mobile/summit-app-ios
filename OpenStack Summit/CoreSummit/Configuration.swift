//
//  Config.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 7/28/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

public struct Configuration {
    
    // MARK: - Static Instances
    
    public static let production = Configuration(.Production)
    
    public static let staging = Configuration(.Staging)
    
    // MARK: - Properties
    
    public let environment: Environment
    
    private let dictionary: [String: String]
    
    // MARK: - Initialization
    
    private init(_ environment: Environment = .Production) {
        
        self.environment = environment
        
        let resourceName = environment.rawValue
        
        let configFilePath: String! = NSBundle(identifier: BundleIdentifier)!.pathForResource(resourceName, ofType: "plist", inDirectory: "Configuration")
        
        let plist = NSDictionary(contentsOfURL: NSURL(fileURLWithPath: configFilePath))
        
        self.dictionary = plist as! [String: String]
    }
    
    // MARK: - Methods
    
    public subscript(key: Key) -> String {
        
        guard let value = self.dictionary[key.rawValue]
            else { fatalError("Value not found for key: \(key.rawValue)") }
        
        return value
    }
}

public extension Configuration {
    
    /// Configuration Keys
    public enum Key: String {
        
        case ServerURL
        case AuthenticationURL
        case ClientIDOpenID
        case SecretOpenID
        case ClientIDServiceAccount
        case SecretServiceAccount
    }
}