//
//  AppDelegate.swift
//  Summit
//
//  Created by Alsey Coleman Miller on 2/18/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Cocoa

@NSApplicationMain
final class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(notification: NSNotification) {
        // Insert code here to initialize your application
        
        // print app info
        print("Launching OpenStack Summit v\(AppVersion) Build \(AppBuild)")
        print("Using Environment: \(AppEnvironment.rawValue)")
        
    }

    func applicationWillTerminate(notification: NSNotification) {
        // Insert code here to tear down your application
        
        
    }
}

