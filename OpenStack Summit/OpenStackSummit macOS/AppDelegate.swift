//
//  AppDelegate.swift
//  Summit
//
//  Created by Alsey Coleman Miller on 2/18/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Cocoa
import CoreSummit

@NSApplicationMain
final class AppDelegate: NSObject, NSApplicationDelegate {
    
    // MARK: - Properties
    
    private var preferencesWindowController: NSWindowController?
    
    // MARK: - NSApplicationDelegate

    func applicationDidFinishLaunching(notification: NSNotification) {
        // Insert code here to initialize your application
        
        // print app info
        print("Launching OpenStack Summit v\(AppVersion) Build \(AppBuild)")
        print("Using Environment: \(AppEnvironment.rawValue)")
        
        // Show preferences
        
        if try! Summit.find(SummitManager.shared.summit.value, context: Store.shared.managedObjectContext) == nil {
            
            showPreferences()
        }
    }

    func applicationWillTerminate(notification: NSNotification) {
        // Insert code here to tear down your application
        
        
    }
    
    func applicationShouldHandleReopen(application: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        
        application.windows.forEach { $0.makeKeyAndOrderFront(application) }
        
        return true
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        
        return false
    }
    
    // MARK: - Actions
    
    @IBAction func showPreferences(sender: AnyObject? = nil) {
        
        preferencesWindowController = NSStoryboard(name: "Main", bundle: nil)
            .instantiateControllerWithIdentifier("Preferences") as? NSWindowController
        
        preferencesWindowController?.showWindow(sender)
    }
}

