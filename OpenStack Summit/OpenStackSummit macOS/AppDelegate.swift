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
    
    static var shared: AppDelegate { return NSApp.delegate as! AppDelegate }
    
    // MARK: - Properties
    
    private var preferencesWindowController: NSWindowController?
    
    lazy var mainWindowController: MainWindowController = NSApp.windows.firstMatching({ $0.windowController is MainWindowController })!.windowController as! MainWindowController
    
    // MARK: - NSApplicationDelegate

    func applicationDidFinishLaunching(notification: NSNotification) {
        // Insert code here to initialize your application
        
        // print app info
        print("Launching OpenStack Summit v\(AppVersion) Build \(AppBuild)")
        print("Using Environment: \(AppEnvironment.rawValue)")
        
        #if DEBUG
        DataUpdatePoller.shared.log = { print("DataUpdatePoller: " + $0) }
        #endif
        
        DataUpdatePoller.shared.start()
        
        //#if DEBUG
        //SummitManager.shared.summit.value = 0
        //try! Store.shared.clear()
        //#endif
        
        // Show preferences
        
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(1 * Double(NSEC_PER_SEC)))
        
        dispatch_after(delayTime, dispatch_get_main_queue()) { [weak self] in
            
            if try! Summit.find(SummitManager.shared.summit.value, context: Store.shared.managedObjectContext) == nil {
                
                self?.showPreferences()
            }
        }
    }

    func applicationWillTerminate(notification: NSNotification) {
        // Insert code here to tear down your application
        
        
    }
    
    func applicationShouldHandleReopen(application: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        
        application.windows
            .filter { $0.className != NSPopover.windowClassName }
            .forEach { $0.makeKeyAndOrderFront(application) }
        
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
        
        preferencesWindowController?.window?.makeKeyAndOrderFront(sender)
    }
}

