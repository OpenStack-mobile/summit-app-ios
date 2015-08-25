//
//  AppDelegate.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/5/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //Crashlytics.sharedInstance().debugMode = true
        //Fabric.with([Crashlytics()])

        // Override point for customization after application launch.
        return true
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
}

