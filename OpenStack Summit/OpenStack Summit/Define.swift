//
//  Version.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/14/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import enum CoreSummit.Environment
import struct CoreSummit.Configuration

/// Version of the app.
public let AppVersion = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String

/// Build of the app.
public let AppBuild = Int(NSBundle.mainBundle().infoDictionary!["CFBundleVersion"] as! String)!

/// The app's environment.
let AppEnvironment: Environment = {
    
    let environmentString = NSBundle.mainBundle().infoDictionary!["SummitEnvironment"] as! String
    
    guard let environment = Environment(rawValue: environmentString)
        else { fatalError("Invalid Environment: \(environmentString)") }
    
    return environment
}()

/// The app's configuration.
let AppConfiguration: Configuration = {
    
    return Configuration(AppEnvironment)
}()