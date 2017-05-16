//
//  AppDelegate.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/14/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import UIKit
import UserNotifications
import CoreSpotlight
import CoreSummit
//import GoogleMaps
import var AeroGearOAuth2.AGAppLaunchedWithURLNotification
import XCDYouTubeKit
import Fabric
import Crashlytics
import FirebaseCore
import FirebaseInstanceID
import FirebaseMessaging

@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate, SummitActivityHandling {
    
    static var shared: AppDelegate { return unsafeBitCast(UIApplication.shared.delegate!, to: AppDelegate.self) }

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // print app info
        print("Launching OpenStack Summit v\(AppVersion) Build \(AppBuild)")
        print("Using Environment: \(AppEnvironment.rawValue)")
        
        // update app build preference
        Preference.appBuild = AppBuild
        
        // setup Fabric
        Crashlytics.start(withAPIKey: AppConsumerKey(AppEnvironment).fabric)
        
        // setup Google Maps
        GMSServices.provideAPIKey(AppConsumerKey(AppEnvironment).googleMaps)
        
        // setup BuddyBuild SDK
        BuddyBuildSDK.setup()
        
        // initialize Store
        let _ = Store.shared
        
        #if MOCKED
        try! Store.shared.clear()
        #endif
        
        // setup data poller
        #if DEBUG
        DataUpdatePoller.shared.log = { print("DataUpdatePoller: " + $0) }
        #endif
        #if !MOCKED
        DataUpdatePoller.shared.start()
        #endif
        
        // validate R.swift on debug builds
        #if DEBUG
        try! R.validate()
        #endif
        
        // configure global appearance
        SetAppearance()
        
        // Core Spotlight
        if CSSearchableIndex.isIndexingAvailable() {
            
            #if DEBUG
            SpotlightController.shared.log = { print("SpotlightController: " + $0) }
            #endif
        }
        
        // Setup Notification Manager
        #if DEBUG
        PushNotificationManager.shared.log = { print("PushNotificationManager: " + $0) }
        #endif
        PushNotificationManager.shared.setupNotifications(application)
        PushNotificationManager.shared.reloadSubscriptions()
        PushNotificationManager.shared.updateAppBadge()
        
        // setup FireBase
        FIRApp.configure()
        FIRMessaging.messaging().remoteMessageDelegate = PushNotificationManager.shared
        
        // Add observer for InstanceID token refresh callback.
        NotificationCenter.default.addObserver(self,
                                                         selector: #selector(self.tokenRefreshNotification),
                                                         name: .firInstanceIDTokenRefresh,
                                                         object: nil)
        
        connectToFcm()
        
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        FIRMessaging.messaging().disconnect()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        connectToFcm()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Swift.Error) {
        
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        print("APNs token retrieved: \(deviceToken)")
        
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: .sandbox)
    }
    
    // HACK: implemented old delegate to make notifications work as is on iOS 10
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        
        // app was just brought from background to foreground
        if application.applicationState == .active {
            
            // called when push notification received in foreground
            print("Recieved remote notification: \(userInfo)")
            
        } else {
            
            // called when push notification tapped
            print("Tapped on remote notification: \(userInfo)")
            
            PushNotificationManager.shared.process(pushNotification: userInfo as! [String: Any], unread: false)
            
            // redirect to inbox
            self.view(screen: .inbox)
        }
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, withResponseInfo responseInfo: [AnyHashable : Any], completionHandler: @escaping () -> Void) {
        
        PushNotificationManager.shared.handleNotification(action: identifier, for: notification, with: responseInfo as! [String: AnyObject], completion: completionHandler)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        var options = [UIApplicationOpenURLOptionsKey : Any]()
        
        if let sourceApplication = sourceApplication {
            
            options[.sourceApplication] = sourceApplication
        }
        
        return self.application(application, open: url, options: options)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        
        if let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String {
            
            let bundleID = Bundle.main.bundleIdentifier
            
            if sourceApplication == bundleID || sourceApplication == "com.apple.SafariViewService" {
                
                let notification = Foundation.Notification (name: Notification.Name(rawValue: AGAppLaunchedWithURLNotification), object: nil, userInfo: [UIApplicationLaunchOptionsKey.url:url])
                NotificationCenter.default.post(notification)
                
                return true
            }
        }
        
        // HACK: async is needed in case app was not already opened
        DispatchQueue.main.async {
            let _ = self.openScheme(url: url)
        }
        
        return false
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        
        print("Continue activity \(userActivity.activityType)\n\(userActivity.userInfo?.description ?? "")")
        
        if userActivity.activityType == CSSearchableItemActionType {
            
            guard let searchIdentifierString = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String,
                let searchURL = Foundation.URL(string: searchIdentifierString),
                searchURL.pathComponents.count == 2
                else { return false }
            
            let searchTypeString = searchURL.pathComponents[0]
            let identifierString = searchURL.pathComponents[1]
            
            guard let dataType = AppActivitySummitDataType(rawValue: searchTypeString),
                let identifier = Identifier(identifierString)
                else { return false }
            
            guard self.canView(data: dataType, identifier: identifier)
                else { return false }
            
            self.view(data: dataType, identifier: identifier)
        }
        
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            
            // parse URL
            guard let url = userActivity.webpageURL
                else { return false }
            
            guard self.openWeb(url: url)
                else { UIApplication.shared.openURL(url); return false }
            
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
    
    // MARK: - Methods
    
    private func connectToFcm() {
        // Won't connect since there is no token
        guard FIRInstanceID.instanceID().token() != nil else {
            return;
        }
        
        // Disconnect previous FCM connection if it exists.
        FIRMessaging.messaging().disconnect()
        
        FIRMessaging.messaging().connect { (error) in
            if error != nil {
                print("Unable to connect with FCM. \(error!)")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    
    // MARK: - Notifications
    
    func tokenRefreshNotification(_ notification: Foundation.Notification) {
        
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            
            print("InstanceID token: \(refreshedToken)")
        }
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    
    // MARK: - SummitActivityHandling
    
    func view(data: AppActivitySummitDataType, identifier: Identifier)  {
        
        guard let topViewController = (self.window?.rootViewController as? UINavigationController)?.topViewController as? SummitActivityHandlingViewController
            else { fatalError("Visible view controller doesn't support deep linking") }
        
        return topViewController.view(data: data, identifier: identifier)
    }
    
    func view(screen: AppActivityScreen) {
        
        guard let topViewController = (self.window?.rootViewController as? UINavigationController)?.topViewController as? SummitActivityHandlingViewController
            else { fatalError("Visible view controller doesn't support deep linking") }
        
        topViewController.view(screen: screen)
    }
    
    func search(_ searchTerm: String) {
        
        guard let topViewController = (self.window?.rootViewController as? UINavigationController)?.topViewController as? SummitActivityHandlingViewController
            else { fatalError("Visible view controller doesn't support deep linking") }
        
        topViewController.search(searchTerm)
    }
}

