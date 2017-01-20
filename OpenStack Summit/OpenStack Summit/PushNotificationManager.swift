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
    
    deinit {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    private init(store: Store = Store.shared) {
        
        self.store = store
        
        super.init()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loggedIn), name: Store.Notification.LoggedIn.rawValue, object: self.store)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loggedOut), name: Store.Notification.LoggedOut.rawValue, object: self.store)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(forcedLoggedOut), name: Store.Notification.ForcedLoggedOut.rawValue, object: self.store)
    }
    
    // MARK: - Methods
    
    public func setupNotifications(application: UIApplication) {
        
        var notificationCategories = Set<UIMutableUserNotificationCategory>()
        
        do {
            
            let replyAction = UIMutableUserNotificationAction()
            replyAction.identifier = TeamMessageNotificationAction.reply.rawValue
            replyAction.title = "Reply"
            replyAction.activationMode = .Background
            replyAction.authenticationRequired = true
            replyAction.destructive = false
            
            if #available(iOS 9.0, *) {
                replyAction.behavior = .TextInput
            }
            
            let notificationCategory = UIMutableUserNotificationCategory()
            notificationCategory.identifier = TeamMessageNotificationAction.category.rawValue
            notificationCategory.setActions([replyAction], forContext: .Default)
            notificationCategory.setActions([replyAction], forContext: .Minimal)
            notificationCategories.insert(notificationCategory)
        }
        
        // Register for remote notifications. This shows a permission dialog on first run, to
        // show the dialog at a more appropriate time move this registration accordingly.
        let settings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: notificationCategories)
        
        application.registerUserNotificationSettings(settings)
        
        application.registerForRemoteNotifications()
    }
    
    public func process(pushNotification: [String: String]) {
        
        let notification: PushNotification?
        
        // parse
        
        if let teamMessageNotification = TeamMessageNotification(pushNotification: pushNotification) {
            
            notification = teamMessageNotification
            
            let teamMessage = TeamMessage(notification: teamMessageNotification)
            
            // cache
            let context = store.privateQueueManagedObjectContext
            context.performBlock {
                
                try! teamMessage.save(context)
                
                try! context.save()
            }
            
            // schedule local notification
            if teamMessage.from.identifier != store.authenticatedMember?.identifier {
                
                let userNotification = UILocalNotification()
                userNotification.userInfo = [UserNotificationUserInfo.topic.rawValue: PushNotificationTopic.team(teamMessage.team.identifier).rawValue]
                userNotification.alertTitle = "\(teamMessageNotification.from.firstName) \(teamMessageNotification.from.lastName)"
                userNotification.alertBody = teamMessageNotification.body
                userNotification.fireDate = NSDate()
                userNotification.category = TeamMessageNotificationAction.category.rawValue
                
                UIApplication.sharedApplication().scheduleLocalNotification(userNotification)
            }
            
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
    
    public func handleNotification(action identifier: String?, for notification: UILocalNotification, with response: [String: AnyObject], completion: () -> ()) {
        
        let category = UserNotificationCategory(rawValue: notification.category!)!
        
        switch category {
            
        case .teamMessage:
            
            let action = TeamMessageNotificationAction(rawValue: identifier!)!
            
            switch action {
                
            case .reply:
                
                guard let topicString = notification.userInfo?[UserNotificationUserInfo.topic.rawValue] as? String,
                    let topic = PushNotificationTopic(rawValue: topicString),
                    case let .team(team) = topic
                    else { completion(); return }
                
                if #available(iOS 9.0, *),
                let replyText = response[UIUserNotificationActionResponseTypedTextKey] as? String {
                    
                    Store.shared.send(replyText, to: team, completion: { [weak self] (response) in
                        
                        switch response {
                            
                        case let .Error(error):
                            
                            self?.log?("Could not send message from local notification: \(error)")
                            
                        case let .Value(newMessage):
                            
                            self?.log?("Sent message from local notification: \(newMessage)")
                        }
                        
                        
                    })
                    
                    completion()
                    
                } else {
                    // Fallback on earlier versions
                    
                }
            }
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
    
    public func startObservingTeams() {
        
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
        
        teams.forEach { subscribe(to: .team($0.identifier)) }
    }
    
    // MARK: - FIRMessagingDelegate
    
    public func applicationReceivedRemoteMessage(remoteMessage: FIRMessagingRemoteMessage) {
        
        process(remoteMessage.appData as! [String: String])
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

// MARK: - Supporting Types

public enum UserNotificationCategory: String {
    
    case teamMessage = "TeamMessageNotification"
}

public enum TeamMessageNotificationAction: String {
    
    public static let category = UserNotificationCategory.teamMessage
    
    case reply
}

public enum UserNotificationUserInfo: String {
    
    case topic
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
    
    init?(pushNotification: [String: String])
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
            static var prefixRegularExpressions = [Prefix: NSRegularExpression]()
        }
        
        func parseIdentifier(prefix: Prefix) -> Identifier? {
            
            let prefixString = "/topics/" + prefix.rawValue + "_"
            
            guard rawValue.containsString(prefixString) else { return nil }
            
            // get regex
            
            let regularExpression: NSRegularExpression
            
            if let cached = Cache.prefixRegularExpressions[prefix] {
                
                regularExpression = cached
                
            } else {
                
                regularExpression = try! NSRegularExpression(pattern: prefixString + "(\\d+)", options: [])
                
                Cache.prefixRegularExpressions[prefix] = regularExpression
            }
            
            // run regex
            
            guard let match = regularExpression.firstMatchInString(rawValue, options: [], range: NSMakeRange(0, (rawValue as NSString).length))
                where match.numberOfRanges == 2
                else { return nil }
            
            let matchString = (rawValue as NSString).substringWithRange(match.range)
            
            guard matchString == rawValue
                else { return nil }
            
            let captureGroup = (rawValue as NSString).substringWithRange(match.rangeAtIndex(1))
            
            guard let identifier = Int(captureGroup)
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
    
    public let identifier: Identifier
    
    public let body: String
    
    public let created: Date
    
    public let team: Identifier
    
    public let from: (idenfitier: Identifier, firstName: String, lastName: String)
    
    public init?(pushNotification: [String: String]) {
        
        guard let topicString = pushNotification[Key.from.rawValue],
            let topic = PushNotificationTopic(rawValue: topicString),
            let typeString = pushNotification[Key.type.rawValue],
            let type = PushNotificationType(rawValue: typeString),
            case let .team(team) = topic,
            let identifierString = pushNotification[Key.id.rawValue],
            let identifier = Int(identifierString),
            let encodedBody = pushNotification[Key.body.rawValue],
            let body = String(openStackEncoded: encodedBody),
            let createdString = pushNotification[Key.created_at.rawValue],
            let created = Int(createdString),
            let fromIDString = pushNotification[Key.from_id.rawValue],
            let fromID = Int(fromIDString),
            let fromFirstName = pushNotification[Key.from_first_name.rawValue],
            let fromLastName = pushNotification[Key.from_last_name.rawValue]
            where type == self.dynamicType.type
            else { return nil }
        
        self.identifier = identifier
        self.team = team
        self.body = body
        self.created = Date(timeIntervalSince1970: TimeInterval(created))
        self.from = (fromID, fromFirstName, fromLastName)
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
        
        case from, id, type, body, summit_id, channel, created_at, event_id, title
    }
    
    public static let type = PushNotificationType.notification
    
    public let identifier: Identifier
    
    public let body: String
    
    public let created: Date
    
    public let from: PushNotificationTopic
    
    public let summit: Identifier
    
    public let channel: Channel
    
    public let event: (identifier: Identifier, title: String)?
    
    public init?(pushNotification: [String: String]) {
        
        guard let topicString = pushNotification[Key.from.rawValue],
            let topic = PushNotificationTopic(rawValue: topicString),
            let typeString = pushNotification[Key.type.rawValue],
            let type = PushNotificationType(rawValue: typeString),
            let identifierString = pushNotification[Key.id.rawValue],
            let identifier = Int(identifierString),
            let body = pushNotification[Key.body.rawValue],
            let createdString = pushNotification[Key.created_at.rawValue],
            let created = Int(createdString),
            let summitIDString = pushNotification[Key.summit_id.rawValue],
            let summitID = Int(summitIDString),
            let channelString = pushNotification[Key.channel.rawValue],
            let channel = Channel(rawValue: channelString)
            where type == self.dynamicType.type
            else { return nil }
        
        self.identifier = identifier
        self.from = topic
        self.body = body
        self.created = Date(timeIntervalSince1970: TimeInterval(created))
        self.summit = summitID
        self.channel = channel
        
        switch channel {
            
        case .event:
            
            guard let eventIDString = pushNotification[Key.event_id.rawValue],
                let eventID = Int(eventIDString),
                let eventTitle = pushNotification[Key.title.rawValue]
                else { return nil }
            
            self.event = (eventID, eventTitle)
            
        default:
            
            self.event = nil
        }
    }
}
