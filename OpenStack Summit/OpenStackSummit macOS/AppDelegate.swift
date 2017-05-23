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
    
    lazy var mainWindowController: MainWindowController = NSApp.windows.first(where: { $0.windowController is MainWindowController })!.windowController as! MainWindowController
    
    // MARK: - NSApplicationDelegate

    func applicationDidFinishLaunching(_ notification: Foundation.Notification) {
        // Insert code here to initialize your application
        
        // print app info
        print("Launching OpenStack Summit v\(AppVersion) Build \(AppBuild)")
        print("Using Environment: \(AppEnvironment.rawValue)")
        
        #if DEBUG
        DataUpdatePoller.shared.log = { print("DataUpdatePoller: " + $0) }
        #endif
        
        DataUpdatePoller.shared.start()
        
    }

    func applicationWillTerminate(_ notification: Foundation.Notification) {
        // Insert code here to tear down your application
        
        
    }
    
    func applicationShouldHandleReopen(_ application: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        
        application.windows
            .filter { $0.className != NSPopover.windowClassName }
            .forEach { $0.makeKeyAndOrderFront(application) }
        
        return true
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        
        return false
    }
    
    func application(_ application: NSApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]) -> Void) -> Bool {
        
        print("Continue activity \(userActivity.activityType)\n\(userActivity.webpageURL?.description ?? "")\n\(userActivity.userInfo?.description ?? "")")
        
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            
            // parse URL
            guard let url = userActivity.webpageURL
                else { return false }
            
            guard mainWindowController.openWeb(url: url)
                else { NSWorkspace.shared().open(url); return false }
            
        } else if userActivity.activityType == AppActivity.view.rawValue {
            
            guard let typeString = userActivity.userInfo?[AppActivityUserInfo.type.rawValue] as? String,
                let dataType = AppActivitySummitDataType(rawValue: typeString),
                let identifier = userActivity.userInfo?[AppActivityUserInfo.identifier.rawValue] as? Identifier
                else { return false }
            
            guard self.canView(data: dataType, identifier: identifier)
                else { return false }
            
            self.view(data: dataType, identifier: identifier)
            
        } else if userActivity.activityType == AppActivity.screen.rawValue {
            
            guard let screenString = userActivity.userInfo?[AppActivityUserInfo.screen.rawValue] as? String,
                let screen = AppActivityScreen(rawValue: screenString)
                else { return false }
            
            self.view(screen: screen)
        }
        
        return false
    }
}

// MARK: - SummitActivityHandling

extension AppDelegate: SummitActivityHandling {
    
    func view(data: AppActivitySummitDataType, identifier: Identifier) {
        
        mainWindowController.view(data: data, identifier: identifier)
    }
    
    func view(screen: AppActivityScreen) {
        
        mainWindowController.view(screen: screen)
    }
    
    func search(_ searchTerm: String) {
        
        mainWindowController.search(searchTerm)
    }
}
