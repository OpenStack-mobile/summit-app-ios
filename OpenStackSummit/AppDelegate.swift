	//
//  AppDelegate.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/5/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
    import UXTesting
import AeroGearOAuth2
import GoogleMaps
import Parse
    
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        //Crashlytics.sharedInstance().debugMode = true
        //Fabric.with([Crashlytics()])

        UXTestingManager.sharedInstance().appKey = "lUMy9RUlm4cQqQeG_1oc_g"
        
        // Override point for customization after application launch.
        GMSServices.provideAPIKey("AIzaSyBnBFBj9ixFjw1OJhAT3FC87JOOS-FuE0Q")
        
        Parse.setApplicationId("WuBfqY41DVcUnY4szatuXhMn0cwwu7YGX152VHEl", clientKey: "AbSHdAekX4l9WgP8PObe6PA2XsnnXUTpsiVP6kcN")
        
        let notificationSettings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
        application.registerForRemoteNotifications()
        
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        
        return true
    }
    
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        // Store the deviceToken in the current installation and save it to Parse.
        let currentInstallation: PFInstallation = PFInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
        currentInstallation.saveInBackground()
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        PFPush.handlePush(userInfo)
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        let notification = NSNotification(name: AGAppLaunchedWithURLNotification, object:nil, userInfo:[UIApplicationLaunchOptionsURLKey:url])
        NSNotificationCenter.defaultCenter().postNotification(notification)
        return true
    }
    
    func applicationWillEnterForeground(application: UIApplication) {
        // yeah, this code is correct. It should delete notification badge when entering app
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }
}
