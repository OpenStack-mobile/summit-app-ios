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
    
    // MARK: - Properties
    
    private(set) var window: NSWindow?
    
    // MARK: - NSApplicationDelegate

    func applicationDidFinishLaunching(notification: NSNotification) {
        // Insert code here to initialize your application
        
        // print app info
        print("Launching OpenStack Summit v\(AppVersion) Build \(AppBuild)")
        print("Using Environment: \(AppEnvironment.rawValue)")
        
        showPreferences()
        
        // show preferences if no summit selected
        if SummitManager.shared.summit.value == 0 {
            
            showPreferences()
        }
    }

    func applicationWillTerminate(notification: NSNotification) {
        // Insert code here to tear down your application
        
        
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        
        return true
    }
    
    // MARK: - Actions
    
    @IBAction func showPreferences(sender: AnyObject? = nil) {
        
        let preferencesWindowController = NSStoryboard(name: "Main", bundle: nil)
            .instantiateControllerWithIdentifier("PreferencesWindowController") as! NSWindowController
        
        preferencesWindowController.showWindow(sender)
    }
}

