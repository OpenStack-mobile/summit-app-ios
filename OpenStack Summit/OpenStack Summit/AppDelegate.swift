//
//  AppDelegate.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/14/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit
import CoreSummit
import SWRevealViewController
import RealmSwift
//import GoogleMaps
import AeroGearOAuth2

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    static var shared: AppDelegate { return unsafeBitCast(UIApplication.sharedApplication().delegate!, AppDelegate.self) }

    var window: UIWindow?
    
    lazy var menuViewController: MenuViewController = R.storyboard.menu.menuViewController()!
        
    lazy var navigationController: UINavigationController = UINavigationController(rootViewController: EventsViewController())
    
    lazy var revealViewController: SWRevealViewController = SWRevealViewController(rearViewController: self.menuViewController, frontViewController: self.navigationController)

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        
        // print app info
        print("Launching OpenStack Summit v\(AppVersion) Build \(AppBuild)")
        print("Using Environment: \(AppEnvironment.rawValue)")
        
        // update app build
        if AppBuild != Preference.appBuild {
            
            // update app build preference
            Preference.appBuild = AppBuild
            
            // nuke cache
            let realmPath = Realm.Configuration.defaultConfiguration.path!
            
            if NSFileManager.defaultManager().fileExistsAtPath(realmPath) {
                
                try! NSFileManager.defaultManager().removeItemAtPath(realmPath)
            }
        }
        
        // set configuration
        Store.shared.configuration = AppConfiguration
        
        // set session storage
        Store.shared.session = UserDefaultsSessionStorage()
        
        // validate R.swift on debug builds
        R.assertValid()
        
        // configure global appearance
        SetAppearance()
                
        // setup Google Maps
        GMSServices.provideAPIKey("Google Maps API Key")
        
        // setup Parse
        //Parse.setApplicationId("Parse App ID", clientKey: "Parse Client Key")
        
        // notifications
        let notificationSettings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: [UIUserNotificationType.Alert, UIUserNotificationType.Badge, UIUserNotificationType.Sound], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
        application.registerForRemoteNotifications()
        
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        
        // setup root VC
        window?.rootViewController = revealViewController
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        // yeah, this code is correct. It should delete notification badge when entering app
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
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

    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        let notification = NSNotification(name: AGAppLaunchedWithURLNotification, object:nil, userInfo:[UIApplicationLaunchOptionsURLKey:url])
        NSNotificationCenter.defaultCenter().postNotification(notification)
        return true
    }
    /*
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        // Store the deviceToken in the current installation and save it to Parse.
        let currentInstallation: PFInstallation = PFInstallation.currentInstallation()
        currentInstallation.setDeviceTokenFromData(deviceToken)
        currentInstallation.saveInBackground()
    }*/
}

