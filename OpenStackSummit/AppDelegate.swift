//
//  AppDelegate.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/5/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Fabric
import Crashlytics
import AeroGearOAuth2
import GoogleMaps
import Parse
import SWRevealViewController
    
@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var securityManager: SecurityManager!
    var revealViewController: SWRevealViewController!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        #if !DEBUG
            Fabric.with([Crashlytics.self])
        #endif
        
        // Override point for customization after application launch.
        GMSServices.provideAPIKey("Google Maps API Key")
        
        Parse.setApplicationId("Parse App ID", clientKey: "Parse Client Key")
        
        let notificationSettings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
        application.registerForRemoteNotifications()
        
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        
        window?.rootViewController = revealViewController
        
        return true
    }
    
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        // Store the deviceToken in the current installation and save it to Parse.
        let currentInstallation: PFInstallation = PFInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
        currentInstallation.saveInBackground()
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        if let aps = userInfo["aps"] as? NSDictionary {
            if let alert = aps["alert"] as? NSDictionary {
                if let message = alert["message"] as? String {
                    SweetAlert().showAlert("", subTitle: message, style: AlertStyle.None)
                }
            } else if let alert = aps["alert"] as? String {
                SweetAlert().showAlert("", subTitle: alert, style: AlertStyle.None)
            }
        }
        completionHandler(UIBackgroundFetchResult.NoData)
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
    
    func applicationDidBecomeActive(application: UIApplication) {
        securityManager.checkPasscodeSettingChange()
    }
}
