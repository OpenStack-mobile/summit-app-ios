//
//  AppDelegate.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/14/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit
import UserNotifications
import CoreSpotlight
import SwiftFoundation
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
    
    lazy var menuViewController: MenuViewController = R.storyboard.menu.menuViewController()!
    
    lazy var revealViewController: SWRevealViewController = SWRevealViewController(rearViewController: self.menuViewController, frontViewController: UINavigationController(rootViewController: self.menuViewController.generalScheduleViewController))
    
    lazy var launchScreenViewController: LaunchScreenViewController = (self.window!.rootViewController as! UINavigationController).viewControllers.first as! LaunchScreenViewController

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        // print app info
        print("Launching OpenStack Summit v\(AppVersion) Build \(AppBuild)")
        print("Using Environment: \(AppEnvironment.rawValue)")
        
        // update app build preference
        Preference.appBuild = AppBuild
        
        // setup Fabric
        Crashlytics.startWithAPIKey(AppConsumerKey(AppEnvironment).fabric)
        
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
        R.assertValid()
        
        // configure global appearance
        SetAppearance()
        
        // Core Spotlight
        if CSSearchableIndex.isIndexingAvailable() {
            
            SpotlightController.shared.log = { print("SpotlightController: " + $0) }
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
                                                         name: kFIRInstanceIDTokenRefreshNotification,
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
        
        #if !DEBUG
        FIRMessaging.messaging().disconnect()
        #endif
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
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
        print("Unable to register for remote notifications: \(error.localizedDescription)")
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        print("APNs token retrieved: \(deviceToken)")
        
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.sandbox)
    }
    
    // HACK: implemented old delegate to make notifications work as is on iOS 10
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        
        // Print message ID.
        if let messageID = userInfo["gcm.message_id"] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print("Recieved remote notification: \(userInfo)")
        
        PushNotificationManager.shared.process(userInfo as! [String: String])
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        
        // Print message ID.
        if let messageID = userInfo["gcm.message_id"] {
            print("Message ID: \(messageID)")
        }
        
        // Print full message.
        print("Recieved remote notification: \(userInfo)")
        
        PushNotificationManager.shared.process(userInfo as! [String: String])
        
        completionHandler(.newData)
    }
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, withResponseInfo responseInfo: [AnyHashable: Any], completionHandler: @escaping () -> Void) {
        
        PushNotificationManager.shared.handleNotification(action: identifier, for: notification, with: responseInfo as! [String: AnyObject], completion: completionHandler)
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
        
        var options = [String : AnyObject]()
        
        if let sourceApplication = sourceApplication {
            
            options[UIApplicationOpenURLOptionsKey.sourceApplication] = sourceApplication
        }
        
        return self.application(application, open: url, options: options)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any]) -> Bool {
        
        if let sourceApplication = options[UIApplicationOpenURLOptionsKey.sourceApplication] as? String {
            
            let bundleID = Bundle.main.bundleIdentifier
            
            if sourceApplication == bundleID || sourceApplication == "com.apple.SafariViewService" {
                
                let notification = Notification(name: AGAppLaunchedWithURLNotification, object: nil, userInfo: [UIApplicationLaunchOptionsKey.url:url])
                NotificationCenter.default.post(notification)
                
                return true
            }
        }
        
        // HACK: async is needed in case app was not already opened
        DispatchQueue.main.async {
            return self.openSchemeURL(url)
        }
        
        return false
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
        
        /// force view load
        let _ = self.revealViewController.view
        let _ = self.menuViewController.view
        let _ = self.revealViewController.frontViewController.view
        
        if self.launchScreenViewController.navigationController?.topViewController == self.launchScreenViewController
            && self.launchScreenViewController.willTransition == false {
            
            self.launchScreenViewController.showRevealController() { self.application(application, continue: userActivity, restorationHandler: restorationHandler) }
            return true
        }
        
        print("Continue activity \(userActivity.activityType)\n\(userActivity.userInfo?.description ?? "")")
        
        if userActivity.activityType == CSSearchableItemActionType {
            
            guard let searchIdentifierString = userActivity.userInfo?[CSSearchableItemActivityIdentifier] as? String,
                let searchURL = Foundation.URL(string: searchIdentifierString),
                searchURL.pathComponents?.count == 2
                else { return false }
            
            let searchTypeString = searchURL.pathComponents![0]
            let identifierString = searchURL.pathComponents![1]
            
            guard let dataType = AppActivitySummitDataType(rawValue: searchTypeString),
                let identifier = Int(identifierString)
                else { return false }
            
            return self.view(dataType, identifier: identifier)
        }
        
        if userActivity.activityType == NSUserActivityTypeBrowsingWeb {
            
            // parse URL
            guard let url = userActivity.webpageURL
                else { return false }
            
            guard openWebURL(url)
                else { UIApplication.shared.openURL(url); return false }
            
        } else if userActivity.activityType == AppActivity.view.rawValue {
            
            guard let typeString = userActivity.userInfo?[AppActivityUserInfo.type.rawValue] as? String,
                let dataType = AppActivitySummitDataType(rawValue: typeString),
                let identifier = userActivity.userInfo?[AppActivityUserInfo.identifier.rawValue] as? Int
                else { return false }
            
            return self.view(dataType, identifier: identifier)
            
        } else if userActivity.activityType == AppActivity.screen.rawValue {
            
            guard let screenString = userActivity.userInfo?[AppActivityUserInfo.screen.rawValue] as? String,
                let screen = AppActivityScreen(rawValue: screenString)
                else { return false }
            
            self.view(screen)
        }
        
        return false
    }
    
    // MARK: - Methods
    
    fileprivate func connectToFcm() {
        // Won't connect since there is no token
        guard FIRInstanceID.instanceID().token() != nil else {
            return;
        }
        
        // Disconnect previous FCM connection if it exists.
        FIRMessaging.messaging().disconnect()
        
        FIRMessaging.messaging().connect { (error) in
            if error != nil {
                print("Unable to connect with FCM. \(error)")
            } else {
                print("Connected to FCM.")
            }
        }
    }
    
    // MARK: - Notifications
    
    func tokenRefreshNotification(_ notification: Notification) {
        
        if let refreshedToken = FIRInstanceID.instanceID().token() {
            
            print("InstanceID token: \(refreshedToken)")
        }
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        connectToFcm()
    }
    
    // MARK: - SummitActivityHandling
    
    func view(_ data: AppActivitySummitDataType, identifier: Identifier) -> Bool  {
        
        // find in cache
        guard let managedObject = try! data.managedObject.find(identifier, context: Store.shared.managedObjectContext)
            else { return false }
        
        switch data {
            
        case .event:
            
            self.menuViewController.showEvents()
            
            let _ = self.menuViewController.generalScheduleViewController.view
            
            let eventDetailVC = R.storyboard.event.eventDetailViewController()!
            eventDetailVC.event = identifier
            self.menuViewController.generalScheduleViewController.show(eventDetailVC, sender: nil)
            
        case .speaker:
            
            self.menuViewController.showSpeakers()
            
            let memberProfileVC = MemberProfileViewController(profile: .speaker(identifier))
            self.menuViewController.speakersViewController.showViewController(memberProfileVC, sender: nil)
            
        case .video:
            
            let video = Video(managedObject: managedObject as! VideoManagedObject)
            
            self.window?.rootViewController?.playVideo(video)
            
        case .venue, .venueRoom:
            
            self.menuViewController.showVenues()
            
            self.menuViewController.venuesViewController.showLocationDetail(identifier)
        }
        
        return true
    }
    
    func view(_ screen: AppActivityScreen) {
        
        switch screen {
            
        case .venues: self.menuViewController.showVenues()
        case .events: self.menuViewController.showEvents()
        case .speakers: self.menuViewController.showSpeakers()
        case .about: self.menuViewController.showAbout()
        }
    }
    
    func search(_ searchTerm: String) {
        
        self.menuViewController.showSearch(for: searchTerm)
    }
}

