//
//  PushNotification.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 12/10/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData
import SwiftFoundation

public extension Store {
    
    func process(pushNotification text: String) {
        
        let group = NotificationGroup(identifier: 0, name: "Push Notifications")
        
        let userID: Identifier?
        
        if let sessionMember = session.member,
            case let .attendee(memberID) = sessionMember {
            
            userID = memberID
            
        } else {
            
            userID = nil
        }
        
        let notification = CoreSummit.Notification(identifier: UUID(), date: Date(), message: text, user: userID, group: group.identifier)
        
        let context = privateQueueManagedObjectContext
        
        context.performBlock {
            
            try! group.save(context)
            
            try! notification.save(context)
        }
    }
}
