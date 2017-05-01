//
//  Login.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/21/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation
import AeroGearHttp
import AeroGearOAuth2
import CoreData

public extension Store {
    
    func logout() {
        
        let context = privateQueueManagedObjectContext
        
        // remove member-specific data from cache
        try! context.performErrorBlockAndWait {
            
            // delete member
            if let member = try self.authenticatedMember(context) {
                
                context.deleteObject(member)
            }
            
            // delete all notifications except 'EVERYBODY' type
            let notifications = try context.managedObjects(NotificationManagedObject.self, predicate: "channel" != CoreSummit.Notification.Channel.everyone.rawValue)
            
            notifications.forEach { context.deleteObject($0) }
            
            try context.validateAndSave()
        }
        
        session.clear()
        
        NSNotificationCenter.defaultCenter().postNotificationName(Notification.LoggedOut.rawValue, object: self)
    }
    
    /// Login via OAuth with OpenStack ID
    func login(summit: Identifier, loginCallback: () -> (), completion: (ErrorType?) -> ()) {
                
        oauthModuleOpenID.login { (accessToken: AnyObject?, claims: OpenIDClaim?, error: NSError?) in // [1]
            
            guard error == nil
                else { completion(error!) ; return }
            
            loginCallback()
            
            self.currentMember(for: summit) { (response) in
                
                switch response {
                    
                case let .Error(error):
                    
                    completion(error)
                    
                case let .Value(member):
                    
                    self.session.name = member.name
                    self.session.member = member.identifier
                    
                    completion(nil)
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(Notification.LoggedIn.rawValue, object: self)
                }
            }
        }
    }
}
