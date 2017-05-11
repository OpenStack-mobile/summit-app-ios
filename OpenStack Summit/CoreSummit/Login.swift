//
//  Login.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/21/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import AeroGearHttp
import AeroGearOAuth2
import CoreData

public extension Store {
    
    func logout() {
        
        let context = privateQueueManagedObjectContext
        
        // remove member from cache
        try! context.performErrorBlockAndWait {
            
            if let member = try self.authenticatedMember(context) {
                
                context.delete(member)
                
                try context.validateAndSave()
            }
        }
        
        session.clear()
        
        NotificationCenter.default.post(name: Store.Notification.loggedOut, object: self)
    }
    
    /// Login via OAuth with OpenStack ID
    func login(_ summit: Identifier, loginCallback: @escaping () -> (), completion: @escaping (Swift.Error?) -> ()) {
        
        oauthModuleOpenID.login { (accessToken: AnyObject?, claims: OpenIdClaim?, error: NSError?) in // [1]
            
            guard error == nil
                else { completion(error!) ; return }
            
            loginCallback()
            
            self.currentMember(for: summit) { (response) in
                
                switch response {
                    
                case let .error(error):
                    
                    completion(error)
                    
                case let .value(member):
                    
                    self.session.name = member.name
                    self.session.member = member.identifier
                    
                    completion(nil)
                    
                    NotificationCenter.default.post(name: Store.Notification.loggedIn, object: self)
                }
            }
        }
    }
}
