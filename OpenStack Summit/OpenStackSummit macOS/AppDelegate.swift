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
    
    func application(application: NSApplication, continueUserActivity userActivity: NSUserActivity, restorationHandler: ([AnyObject]) -> Void) -> Bool {
        
        print("Continue activity \(userActivity.activityType)\n\(userActivity.webpageURL?.description ?? "")\n\(userActivity.userInfo?.description ?? "")")
        
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            
            // parse URL
            guard let url = userActivity.webpageURL
                else { return false }
            
            guard mainWindowController.openWebURL(url)
                else { NSWorkspace.sharedWorkspace().openURL(url); return false }
            
        } else if userActivity.activityType == AppActivity.view.rawValue {
            
            guard let typeString = userActivity.userInfo?[AppActivityUserInfo.type.rawValue] as? String,
                let dataType = AppActivitySummitDataType(rawValue: typeString),
                let identifier = userActivity.userInfo?[AppActivityUserInfo.identifier.rawValue] as? Int
                else { return false }
            
            return mainWindowController.view(dataType, identifier: identifier)
            
        } else if userActivity.activityType == AppActivity.screen.rawValue {
            
            guard let screenString = userActivity.userInfo?[AppActivityUserInfo.screen.rawValue] as? String,
                let screen = AppActivityScreen(rawValue: screenString)
                else { return false }
            
            mainWindowController.view(screen)
        }
        
        return false
    }
}
