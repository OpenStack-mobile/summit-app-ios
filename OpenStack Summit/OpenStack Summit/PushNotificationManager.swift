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

public final class PushNotificationManager: NSObject, NSFetchedResultsControllerDelegate, FIRMessagingDelegate {
    
    public static let shared = PushNotificationManager()
    
    public let store: Store
    
    public var log: ((String) -> ())?
    
    private var teamsFetchedResultsController: NSFetchedResultsController?
    
    private var teams: [Team] {
        
        return Team.from(managedObjects: teamsFetchedResultsController?.fetchedObjects as? [TeamManagedObject] ?? [])
    }
    
    // MARK: - Initialization
    
    private init(store: Store = Store.shared) {
        
        self.store = store
        
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loggedIn), name: Store.Notification.LoggedIn.rawValue, object: self.store)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loggedOut), name: Store.Notification.LoggedOut.rawValue, object: self.store)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(forcedLoggedOut), name: Store.Notification.ForcedLoggedOut.rawValue, object: self.store)
        
        startObservingTeams()
    }
    
    // MARK: - Methods
    
    public func process(pushNotification: [String: AnyObject]) {
        
        let notification: PushNotification?
        
        // parse
        
        if let teamMessageNotification = TeamMessageNotification(pushNotification: pushNotification) {
            
            notification = teamMessageNotification
            
            let teamMessage = TeamMessage(notification: teamMessageNotification)
            
            try! teamMessage.save(store.managedObjectContext)
            
        } else if let generalNotification = GeneralNotification(pushNotification:pushNotification) {
            
            notification = generalNotification
            
        } else {
            
            notification = nil
        }
        
        if let notification = notification {
            
            log?("Got push notification: \(notification)")
            
        } else {
            
            log?("Could not parse push notification: \(pushNotification)")
        }
    }
    
    @inline(__always)
    private func subscribe(to topic: PushNotificationTopic) {
        
        FIRMessaging.messaging().subscribeToTopic(topic.rawValue)
        
        log?("Subscribed to \(topic.rawValue)")
    }
    
    @inline(__always)
    private func unsubscribe(from topic: PushNotificationTopic) {
        
        FIRMessaging.messaging().unsubscribeFromTopic(topic.rawValue)
        
        log?("Unsubscribed from \(topic.rawValue)")
    }
    
    private func startObservingTeams() {
        
        // unsubscribe to current teams
        
        teams.forEach { unsubscribe(from: .team($0.identifier)) }
        
        // fetch member's teams
        
        guard let member = self.store.authenticatedMember else {
            
            self.teamsFetchedResultsController = nil
            return
        }
        
        let predicate = NSPredicate(format: "owner == %@ || members.member CONTAINS %@", member, member)
        
        let sort = [NSSortDescriptor(key: "id", ascending: true)]
        
        teamsFetchedResultsController = NSFetchedResultsController(Team.self, delegate: self, predicate: predicate, sortDescriptors: sort, sectionNameKeyPath: nil, context: store.managedObjectContext)
        
        try! teamsFetchedResultsController!.performFetch()
    }
    
    // MARK: - FIRMessagingDelegate
    
    public func applicationReceivedRemoteMessage(remoteMessage: FIRMessagingRemoteMessage) {
        
        log?("Got Firebase message: \(remoteMessage.appData)")
        
        process(remoteMessage.appData as! [String: AnyObject])
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    public func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        let identifier = (anObject as! Entity).identifier
        
        let topic = PushNotificationTopic.team(identifier)
        
        switch type {
            
        case .Insert: subscribe(to: topic)
            
        case .Delete: unsubscribe(from: topic)
            
        case .Move, .Update: break
        }
    }
    
    // MARK: - Notifications
    
    @objc private func loggedIn(notification: NSNotification) {
        
        startObservingTeams()
    }
    
    @objc private func loggedOut(notification: NSNotification) {
        
        startObservingTeams()
    }
    
    @objc private func forcedLoggedOut(notification: NSNotification) {
        
        startObservingTeams()
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
    
    private enum Prefix: String {
        
        case summit, member, event, team, attendees, speakers, everyone
        
        init(_ topic: PushNotificationTopic) {
            
            switch topic {
                
            case .summit:       self = .summit
            case .team:         self = .team
            case .member:       self = .member
            case .event:        self = .event
            case .attendees:    self = .attendees
            case .speakers:     self = .speakers
            case .everyone:     self = .everyone
            }
        }
    }
    
    public init?(rawValue: String) {
        
        struct Cache {
            static var prefixRegularExpressions = [Prefix: RegularExpression]()
        }
        
        func parseIdentifier(prefix: Prefix) -> Identifier? {
            
            let prefixString = "/topics/" + prefix.rawValue + "_"
            
            guard rawValue.containsString(prefixString) else { return nil }
            
            // get regex
            
            let regularExpression: RegularExpression
            
            if let cached = Cache.prefixRegularExpressions[prefix] {
                
                regularExpression = cached
                
            } else {
                
                regularExpression = try! RegularExpression(prefixString + "(\\d+)")
                
                Cache.prefixRegularExpressions[prefix] = regularExpression
            }
            
            // run regex
            
            guard let match = regularExpression.match(rawValue),
                let substring = rawValue.substring(match.range),
                let identifier = Int(substring)
                else { return nil }
            
            return identifier
        }
        
        func parseCollection() -> PushNotificationTopic? {
            
            guard let prefix = Prefix(rawValue: rawValue)
                else { return nil }
            
            switch prefix {
            case .attendees: return .attendees
            case .everyone: return .everyone
            case .speakers: return .speakers
            default: return nil
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
        
        var stringValue = "/topics/" + Prefix(self).rawValue
        
        if let identifier = self.identifier {
            
            stringValue += "_\(identifier)"
        }
        
        return stringValue
    }
}

public struct TeamMessageNotification: PushNotification {
    
    private enum Key: String {
        
        case from, id, type, body, from_id, from_first_name, from_last_name, created_at
    }
    
    public static let type = PushNotificationType.team
    
    public let team: Identifier
    
    public let identifier: Identifier
    
    public let body: String
    
    public let created: Date
    
    public let from: (idenfitier: Identifier, firstName: String, lastName: String)
    
    public init?(pushNotification: [String: AnyObject]) {
        
        return nil
        
        /*
        
        guard let topicString = pushNotification[Key.from.rawValue] as? String,
            let topic = PushNotificationTopic(rawValue: topicString),
            let typeString = pushNotification[Key.type.rawValue] as? String,
            let type = PushNotificationType(rawValue: channelString),
            case let .team(team) = topic,
            let identifier = pushNotification[Key.id.rawValue] as? Int,
            let body = pushNotification[Key.body.rawValue] as? String,
            let created = pushNotification[Key.created_at.rawValue] as? Int,
            let fromID = pushNotification[Key.from_id.rawValue] as? Int
        */
    }
}

public extension TeamMessage {
    
    init(notification: TeamMessageNotification) {
        
        self.identifier = notification.identifier
        self.body = notification.body
        self.created = notification.created
        self.from = .identifier(notification.from.idenfitier)
        self.team = .identifier(notification.team)
    }
}

public struct GeneralNotification: PushNotification {
    
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
    
    public let from: PushNotificationTopic
    
    public let identifier: Identifier
    
    public let body: String
    
    public let created: Date
    
    public let summit: Identifier
    
    public let channel: Channel
    
    public let event: (identifier: Identifier, title: String)?
    
    public init?(pushNotification: [String: AnyObject]) {
        
        /*
        guard let topicString = pushNotification[Key.from.rawValue] as? String,
        let topic = PushNotificationTopic(rawValue: topicString),
        let channelString = pushNotification[Key.channel.rawValue] as? String,
        let channel = PushNotificationType(rawValue: channelString),
        case let .team(team) = topic,
        let identifier = pushNotification[Key.id.rawValue] as? Int,
        let body = pushNotification[Key.body.rawValue] as? String,
        let created = pushNotification[Key.created_at.rawValue] as? Int,
        let fromID = pushNotification[Key.from_id.rawValue] as? Int*/
        
        fatalError()
    }
}
