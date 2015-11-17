//
//  AppDelegate.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/5/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import AeroGearOAuth2
import GoogleMaps

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //Crashlytics.sharedInstance().debugMode = true
        //Fabric.with([Crashlytics()])

        // Override point for customization after application launch.
        GMSServices.provideAPIKey("Google Maps API Key")
        return true
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        let notification = NSNotification(name: AGAppLaunchedWithURLNotification, object:nil, userInfo:[UIApplicationLaunchOptionsURLKey:url])
        NSNotificationCenter.defaultCenter().postNotification(notification)
        return true
    }
}
