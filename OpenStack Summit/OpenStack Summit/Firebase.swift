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

public final class FirebaseManager: NSObject, FIRMessagingDelegate {
    
    public static let shared = FirebaseManager()
    
    public let store = Store.shared
    
    // MARK: - FIRMessagingDelegate
    
    public func applicationReceivedRemoteMessage(remoteMessage: FIRMessagingRemoteMessage) {
        
        print("Got Firebase message:", remoteMessage.appData)
    }
}

public enum FirebaseMessageType: String {
    
    case team = "TEAM_MESSAGE"
    case notification = "PUSH_NOTIFICATION"
}

public protocol FirebaseMessage {
    
    static var type: FirebaseMessageType { get }
    
    var identifier: Identifier { get }
    
    var body: String { get }
    
    var created: Date { get }
}

public struct FirebaseTeamMessage: FirebaseMessage {
    
    public static let type = FirebaseMessageType.team
    
    public let identifier: Identifier
    
    public let body: String
    
    public let created: Date
    
    public let from: (idenfitier: Identifier, firstName: String, lastName: String)
}

public struct FirebasePushNotification: FirebaseMessage {
    
    public enum Channel: String {
        
        case everyone = "EVERYONE"
        case speakers = "SPEAKERS"
        case attendess = "ATTENDEES"
        case members = "MEMBERS"
        case summit = "SUMMIT"
        case event = "EVENT"
        case group = "GROUP"
    }
    
    public static let type = FirebaseMessageType.notification
    
    public let identifier: Identifier
    
    public let body: String
    
    public let created: Date
    
    public let summit: Identifier
    
    public let channel: Channel
    
    public let event: (identifier: Identifier, title: String)?
}
