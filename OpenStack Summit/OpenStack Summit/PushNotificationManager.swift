//
//  PushNotificationManager.swift
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

public final class PushNotificationManager: NSObject, FIRMessagingDelegate {
    
    public static let shared = PushNotificationManager()
    
    public let store: Store
    
    private var teamsFetchedResultsController: NSFetchedResultsController!
    
    // MARK: - Initialization
    
    private init(store: Store = Store.shared) {
        
        self.store = store
        
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loggedIn), name: Store.Notification.LoggedIn.rawValue, object: self.store)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loggedOut), name: Store.Notification.LoggedOut.rawValue, object: self.store)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(forcedLoggedOut), name: Store.Notification.ForcedLoggedOut.rawValue, object: self.store)
    }
    
    // MARK: - Methods
    
    public func process(pushNotification: [String: AnyObject]) {
        
        let message: PushNotification?
        
        // parse
        
        if let teamMessage = TeamMessageNotification(pushNotification: pushNotification) {
            
            message = teamMessage
            
        } else if let generalMessage = GeneralMessageNotification(pushNotification:pushNotification) {
            
            message = generalMessage
            
        } else {
            
            message = nil
        }
        
        print("Got push notification: \(message)")
        
        
    }
    
    // MARK: - FIRMessagingDelegate
    
    public func applicationReceivedRemoteMessage(remoteMessage: FIRMessagingRemoteMessage) {
        
        print("Got Firebase message:", remoteMessage.appData)
        
        process(remoteMessage.appData as! [String: AnyObject])
    }
    
    // MARK: - Notifications
    
    @objc private func loggedIn(notification: NSNotification) {
        
        
    }
    
    @objc private func loggedOut(notification: NSNotification) {
        
        
    }
    
    @objc private func forcedLoggedOut(notification: NSNotification) {
        
        
    }
}

public enum PushNotificationType: String {
    
    case team = "TEAM_MESSAGE"
    case notification = "PUSH_NOTIFICATION"
}

public protocol PushNotification {
    
    static var type: PushNotificationType { get }
    
    var identifier: Identifier { get }
    
    var body: String { get }
    
    var created: Date { get }
    
    //init?(pushNotification: [String: AnyObject])
}

public enum PushNotificationTopic {
    
    case summit(Identifier)
    case team(Identifier)
    case member(Identifier)
    case event(Identifier)
    case attendees
    case speakers
    case everyone
    
    public var identifier: Identifier? {
        
        switch self {
        case let .summit(identifier): return identifier
        case let .team(identifier): return identifier
        case let .member(identifier): return identifier
        case let .event(identifier): return identifier
        default: return nil
        }
    }
    
    /// Prefixes of topics that include a identifier
    private enum InstanceTopicPrefix: String {
        
        case summit, member, event, team
    }
    
    /// Prefixes of topics that don't include a identifier
    private enum CollectionTopicPrefix: String {
        
        case attendees, speakers, everyone
    }
    
    public init?(rawValue: String) {
        
        struct Cache {
            static var instanceTopicRegularExpressions = [InstanceTopicPrefix: RegularExpression]()
        }
        
        func parseIdentifier(prefix: InstanceTopicPrefix) -> Identifier? {
            
            let prefixString = "/topics/" + prefix.rawValue + "_"
            
            guard rawValue.containsString(prefixString) else { return nil }
            
            // get regex
            
            let regularExpression: RegularExpression
            
            if let cached = Cache.instanceTopicRegularExpressions[prefix] {
                
                regularExpression = cached
                
            } else {
                
                regularExpression = try! RegularExpression(prefixString + "(\\d+)")
                
                Cache.instanceTopicRegularExpressions[prefix] = regularExpression
            }
            
            // run regex
            
            guard let match = regularExpression.match(rawValue),
                let substring = rawValue.substring(match.range),
                let identifier = Int(substring)
                else { return nil }
            
            return identifier
        }
        
        func parseCollection() -> PushNotificationTopic? {
            
            guard let collectionTopic = CollectionTopicPrefix(rawValue: rawValue)
                else { return nil }
            
            switch collectionTopic {
            case .attendees: return .attendees
            case .everyone: return .everyone
            case .speakers: return .speakers
            }
        }
        
        // main `if-else` parsing statement
        
        if let collectionTopic = parseCollection() {
            
            self = collectionTopic
            
        } else if let identifier = parseIdentifier(.summit) {
            
            self = .summit(identifier)
            
        } else if let identifier = parseIdentifier(.member) {
            
            self = .member(identifier)
            
        } else if let identifier = parseIdentifier(.event) {
            
            self = .event(identifier)
            
        } else if let identifier = parseIdentifier(.team) {
            
            self = .team(identifier)
            
        } else {
            
            return nil
        }
    }
    
    public var rawValue: String {
        
        if let identifier = self.identifier {
            
            
            
        } else {
            
            
        }
    }
}

public struct TeamMessageNotification: PushNotification {
    
    private enum Key: String {
        
        case id, type, body, from_id, from_first_name, from_last_name, created_at
    }
    
    public static let type = PushNotificationType.team
    
    public let identifier: Identifier
    
    public let body: String
    
    public let created: Date
    
    public let from: (idenfitier: Identifier, firstName: String, lastName: String)
    
    public init?(pushNotification: [String: AnyObject]) {
        
        fatalError()
    }
}

/*
public extension TeamMessage {
    
    init(notification: TeamMessageNotification) {
        
        self.identifier = notification.identifier
        self.body = notification.body
        self.created = notification.created
        self.from = .identifier(from.identifier)
        self.team = .identifier(<#T##Identifier#>)
    }
}*/

public struct GeneralMessageNotification: PushNotification {
    
    public enum Channel: String {
        
        case everyone = "EVERYONE"
        case speakers = "SPEAKERS"
        case attendess = "ATTENDEES"
        case members = "MEMBERS"
        case summit = "SUMMIT"
        case event = "EVENT"
        case group = "GROUP"
    }
    
    private enum Key: String {
        
        case id, type, body, summit_id, channel, created_at, event_id, title
    }
    
    public static let type = PushNotificationType.notification
    
    public let identifier: Identifier
    
    public let body: String
    
    public let created: Date
    
    public let summit: Identifier
    
    public let channel: Channel
    
    public let event: (identifier: Identifier, title: String)?
    
    public init?(pushNotification: [String: AnyObject]) {
        
        fatalError()
    }
}
