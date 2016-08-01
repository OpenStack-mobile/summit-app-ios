//
//  Login.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/21/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation
import RealmSwift
import AeroGearHttp
import AeroGearOAuth2

public extension Store {
    
    /// The member that is logged in.
    var authenticatedMember: RealmMember? {
        
        guard let member = RealmMember.find(member.identifier, realm: self.realm)
            else { return nil }
    }
    
    var isLoggedIn: Bool {
        
        guard let session = self.session
            else { return false }
        
        return 
        
        checkState()
        return session.get(kCurrentMemberId) != nil
    }
    
    public func isLoggedInAndConfirmedAttendee() -> Bool {
        let currentMemberId = session.get(kCurrentMemberId) as? Int
        return isLoggedIn() && currentMemberId != kLoggedInNotConfirmedAttendee;
    }
    
    func login(summit: Identifier? = nil, completion: (ErrorValue<()>) -> ()) {
        
        oauthModuleOpenID.login { (accessToken: AnyObject?, claims: OpenIDClaim?, error: NSError?) in // [1]
            
            /*
             if error != nil {
             printerr(error)
             Crashlytics.sharedInstance().recordError(error!)
             return
             }
             
             partialCompletionBlock()
             
             if accessToken == nil {
             return
             }
             
             
             self.linkAttendeeIfExist(completionBlock);
             */
            
            guard error == nil
                else { completion(.Error(error!)) ; return }
            
            // link attendee
            
            self.loggedInMember(summit) { (response) in
                
                switch response {
                    
                case let .Error(error):
                    
                    completion(.Error(error))
                    
                case let .Value(member):
                    
                    // save
                    self.authenticatedMember = RealmMember.find(member.identifier, realm: self.realm)!
                    
                    completion(.Value())
                }
            }
        }
    }
}
