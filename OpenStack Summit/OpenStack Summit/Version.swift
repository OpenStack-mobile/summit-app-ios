//
//  Version.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/14/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation

/** Version of the app. */
public let AppVersion = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String

/** Build of the app. */
public let AppBuild = NSBundle.mainBundle().infoDictionary!["CFBundleVersion"] as! String