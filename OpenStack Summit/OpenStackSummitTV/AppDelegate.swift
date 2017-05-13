//
//  AppDelegate.swift
//  OpensStackSummitTV
//
//  Created by Alsey Coleman Miller on 9/4/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit
import Foundation
import CoreSummit

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // print app info
        print("Launching OpenStack Summit (tvOS) v\(AppVersion) Build \(AppBuild)")
        print("Using Environment: \(AppEnvironment.rawValue)")
        
        // set appearance
        SetAppearance()
        
        #if DEBUG
        DataUpdatePoller.shared.log = { print("DataUpdatePoller: " + $0) }
        #endif
        
        // start data poller
        DataUpdatePoller.shared.start()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        
        return open(url: url)
    }
    
    // MARK: - Private Methods
    
    private func open(url: URL) -> Bool {
        
        print("App should open URL: \(url)")
        
        switch url.scheme ?? "" {
            
        case ServiceURL.scheme:
            
            guard let serviceURL = ServiceURL(url: url),
                let video = try! Video.find(serviceURL.identifier, context: Store.shared.managedObjectContext)
                else { return false }
            
            self.window!.rootViewController!.play(video: video)
            
            return true
            
        default: return false
        }
    }
}

