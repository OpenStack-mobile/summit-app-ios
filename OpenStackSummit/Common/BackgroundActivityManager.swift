//
//  BackgroundActivityManager.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/22/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IBackgroundActivityManager {
    func notifyBackgroundActivityStarted()
    func notifyBackgroundActivityEnded()
}

public class BackgroundActivityManager: NSObject {
    public func notifyBackgroundActivityStarted() {
        /*let notification = NSNotification(name: Constants.Notifications.BackgroundActivityStarted, object:nil, userInfo:nil)
        NSNotificationCenter.defaultCenter().postNotification(notification)*/
    }

    public func notifyBackgroundActivityEnded() {
        /*let notification = NSNotification(name: Constants.Notifications.BackgroundActivityEnded, object:nil, userInfo:nil)
        NSNotificationCenter.defaultCenter().postNotification(notification)*/
    }
}
