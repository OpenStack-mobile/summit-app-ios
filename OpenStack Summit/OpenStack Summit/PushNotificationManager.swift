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
    
    private var summitObserver: Int!
    
    private var teamsFetchedResultsController: NSFetchedResultsController?
    
    private var teams: Set<Identifier> {
        
        return (teamsFetchedResultsController?.fetchedObjects as? [Entity] ?? []).identifiers
    }
    
    private var eventsFetchedResultsController: NSFetchedResultsController?
    
    private var events: Set<Identifier> {
        
        return (eventsFetchedResultsController?.fetchedObjects as? [Entity] ?? []).identifiers
    }
    
    // MARK: - Initialization
    
    deinit {
        
        SummitManager.shared.summit.remove(summitObserver)
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    private init(store: Store = Store.shared) {
        
        self.store = store
        
        super.init()
        
        self.summitObserver = SummitManager.shared.summit.observe(summitChanged)
        
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
        
        let backgroundState = UIApplication.sharedApplication().applicationState == .Background
        
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
            if backgroundState && teamMessage.from.identifier != store.authenticatedMember?.identifier {
                
                let userNotification = UILocalNotification()
                userNotification.userInfo = [UserNotificationUserInfo.topic.rawValue: Notification.Topic.team(teamMessage.team.identifier).rawValue]
                userNotification.alertTitle = "\(teamMessageNotification.from.firstName) \(teamMessageNotification.from.lastName)"
                userNotification.alertBody = teamMessageNotification.body
                userNotification.fireDate = NSDate()
                userNotification.category = TeamMessageNotificationAction.category.rawValue
                
                UIApplication.sharedApplication().scheduleLocalNotification(userNotification)
            }
            
        } else if let generalNotification = GeneralNotification(pushNotification:pushNotification) {
            
            notification = generalNotification
            
            let encodable = Notification(notification: generalNotification)
            
            // cache
            let context = store.privateQueueManagedObjectContext
            context.performBlock {
                
                try! encodable.save(context)
                
                try! context.save()
            }
            
            // show notification
            
            if backgroundState {
                
                let userNotification = UILocalNotification()
                userNotification.userInfo = [UserNotificationUserInfo.topic.rawValue: generalNotification.from.rawValue]
                userNotification.alertTitle = generalNotification.event?.title
                userNotification.alertBody = generalNotification.body
                userNotification.fireDate = NSDate()
                userNotification.category = UserNotificationCategory.generalNotification.rawValue
                
                UIApplication.sharedApplication().scheduleLocalNotification(userNotification)
            }
                        
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
                    let topic = Notification.Topic(rawValue: topicString),
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
            
        case .generalNotification:
            
            break
            
        }
    }
    
    public func reloadSubscriptions() {
        
        subscribe(to: .everyone)
        
        let summit = SummitManager.shared.summit.value
        
        if summit > 0 {
            
            subscribe(to: .summit(summit))
        }
        
        startObservingUser()
        
        startObservingTeams()
    }
    
    @inline(__always)
    private func subscribe(to topic: Notification.Topic) {
        
        FIRMessaging.messaging().subscribeToTopic(topic.rawValue)
        
        log?("Subscribed to \(topic.rawValue)")
    }
    
    @inline(__always)
    private func unsubscribe(from topic: Notification.Topic) {
        
        FIRMessaging.messaging().unsubscribeFromTopic(topic.rawValue)
        
        log?("Unsubscribed from \(topic.rawValue)")
    }
    
    private func startObservingTeams() {
        
        // unsubscribe to current teams
        
        teams.forEach { unsubscribe(from: .team($0)) }
        
        // fetch member's teams
        
        guard let member = self.store.authenticatedMember else {
            
            self.teamsFetchedResultsController = nil
            return
        }
        
        let predicate = NSPredicate(format: "owner == %@ || members.member CONTAINS %@", member, member)
        
        let sort = [NSSortDescriptor(key: "id", ascending: true)]
        
        teamsFetchedResultsController = NSFetchedResultsController(Team.self, delegate: self, predicate: predicate, sortDescriptors: sort, sectionNameKeyPath: nil, context: store.managedObjectContext)
        
        try! teamsFetchedResultsController!.performFetch()
        
        teams.forEach { subscribe(to: .team($0)) }
    }
    
    private func startObservingUser() {
        
        let member = self.store.authenticatedMember
        
        if member?.speakerRole != nil {
            
            subscribe(to: .speakers)
            
        } else {
            
            unsubscribe(from: .speakers)
        }
        
        events.forEach { unsubscribe(from: .event($0)) }
        
        if let attendeeRole = member?.attendeeRole {
            
            subscribe(to: .attendees)
            
            let predicate = NSPredicate(format: "attendees CONTAINS %@", attendeeRole)
            
            let sort = [NSSortDescriptor(key: "id", ascending: true)]
            
            eventsFetchedResultsController = NSFetchedResultsController(Event.self, delegate: self, predicate: predicate, sortDescriptors: sort, sectionNameKeyPath: nil, context: store.managedObjectContext)
            
            try! eventsFetchedResultsController!.performFetch()
            
            events.forEach { subscribe(to: .event($0)) }
            
        } else {
            
            unsubscribe(from: .attendees)
        }
    }
    
    private func summitChanged(newValue: Identifier, oldValue: Identifier) {
        
        unsubscribe(from: .summit(oldValue))
        subscribe(to: .summit(newValue))
    }
    
    // MARK: - FIRMessagingDelegate
    
    public func applicationReceivedRemoteMessage(remoteMessage: FIRMessagingRemoteMessage) {
        
        process(remoteMessage.appData as! [String: String])
    }
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    public func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        
        let identifier = (anObject as! Entity).identifier
        
        let topic: Notification.Topic
        
        if controller === teamsFetchedResultsController {
            
            topic = .team(identifier)
            
        } else if controller == eventsFetchedResultsController {
            
            topic = .event(identifier)
            
        } else {
            
            fatalError("Unknown fetched results controller \(controller)")
        }
        
        switch type {
            
        case .Insert: subscribe(to: topic)
            
        case .Delete: unsubscribe(from: topic)
            
        case .Move, .Update: break
        }
    }
    
    // MARK: - Notifications
    
    @objc private func loggedIn(notification: NSNotification) {
        
        reloadSubscriptions()
    }
    
    @objc private func loggedOut(notification: NSNotification) {
        
        reloadSubscriptions()
    }
    
    @objc private func forcedLoggedOut(notification: NSNotification) {
        
        reloadSubscriptions()
    }
}

// MARK: - Supporting Types

public enum UserNotificationCategory: String {
    
    case teamMessage
    case generalNotification
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
            let topic = Notification.Topic(rawValue: topicString),
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
    
    private enum Key: String {
        
        case from, id, type, body, summit_id, channel, created_at, event_id, title
    }
    
    public static let type = PushNotificationType.notification
    
    public let identifier: Identifier
    
    public let body: String
    
    public let created: Date
    
    public let from: Notification.Topic
    
    public let summit: Identifier
    
    public let channel: Notification.Channel
    
    public let event: (identifier: Identifier, title: String)?
    
    public init?(pushNotification: [String: String]) {
        
        guard let topicString = pushNotification[Key.from.rawValue],
            let topic = Notification.Topic(rawValue: topicString),
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
            let channel = Notification.Channel(rawValue: channelString)
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

extension Notification {
    
    init(notification: GeneralNotification) {
        
        self.identifier = notification.identifier
        self.body = notification.body
        self.created = notification.created
        self.from = notification.from
        self.summit = notification.summit
        self.channel = notification.channel
        self.event = notification.event?.identifier
    }
}
