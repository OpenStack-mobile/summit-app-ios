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
        
        session.clear()
        
        NSNotificationCenter.defaultCenter().postNotificationName(Notification.LoggedOut.rawValue, object: self)
    }
    
    /// Login via OAuth with OpenStack ID
    func login(summit: Identifier, loginCallback: () -> (), completion: (ErrorValue<()>) -> ()) {
        
        let context = self.privateQueueManagedObjectContext
        
        oauthModuleOpenID.login { (accessToken: AnyObject?, claims: OpenIDClaim?, error: NSError?) in // [1]
            
            guard error == nil
                else { completion(.Error(error!)) ; return }
            
            loginCallback()
            
            self.currentMember(for: summit) { (response) in
                
                switch response {
                    
                case let .Error(error):
                    
                    completion(.Error(error))
                    
                case let .Value(member):
                    
                    self.session.name = member.name
                    self.session.member = member.identifier
                    
                    completion(.Value())
                    
                    NSNotificationCenter.defaultCenter().postNotificationName(Notification.LoggedIn.rawValue, object: self)
                }
            }
        }
    }
}
