//
//  PushNotificationsManager.swift
//  OpenStackSummit
//
//  Created by Claudio on 11/26/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Parse

@objc
public protocol IPushNotificationsManager {
    func subscribeToPushChannelsUsingContext(completionBlock: (succeeded: Bool, error: NSError?) -> Void)
    func unsubscribeFromPushChannels(completionBlock: (succeeded: Bool, error: NSError?) -> Void)    
}

public class PushNotificationsManager: NSObject, IPushNotificationsManager {
    var securityManager: SecurityManager!
    var summitDataStore: ISummitDataStore!
    
    public func subscribeToPushChannelsUsingContext(completionBlock: (succeeded: Bool, error: NSError?) -> Void) {
        //TODO: add summit12
        if let member = self.securityManager.getCurrentMember() {
            var channels = ["m_\(member.id)", "attendees"]
            if member.speakerRole != nil {
                channels.append("speakers")
            }
            PFInstallation.currentInstallation().channels = channels
            PFInstallation.currentInstallation().saveEventually(completionBlock)        }
    }
    
    public func unsubscribeFromPushChannels(completionBlock: (succeeded: Bool, error: NSError?) -> Void) {
        PFInstallation.currentInstallation().channels = []
        PFInstallation.currentInstallation().saveEventually(completionBlock)
    }
}
