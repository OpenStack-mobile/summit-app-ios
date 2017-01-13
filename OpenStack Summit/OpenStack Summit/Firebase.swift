//
//  Firebase.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 1/13/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import CoreData
import SwiftFoundation
import CoreSummit
import FirebaseCore
import FirebaseMessaging

public final class MessageManager: NSObject, FIRMessagingDelegate {
    
    public static let shared = MessageManager()
    
    public let store = Store.shared
    
    // MARK: - FIRMessagingDelegate
    
    public func applicationReceivedRemoteMessage(remoteMessage: FIRMessagingRemoteMessage) {
        
        
    }
}
