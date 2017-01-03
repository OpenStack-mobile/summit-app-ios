//
//  TeamInvitationRequest.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 1/3/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import SwiftFoundation
import CoreData

public extension Store {
    
    func accept(invitation identifier: Identifier, completion: (ErrorType?) -> ()) {
        
        let uri = "api/v1/members/me/team-invitations/\(identifier)"
        
        let url = environment.configuration.serverURL + uri
        
        let http = self.createHTTP(.OpenIDJSON)
        
        http.PUT(url) { (responseObject, error) in
            
            completion(error)
        }
    }
    
    func decline(invitation identifier: Identifier, completion: (ErrorType?) -> ()) {
        
        let uri = "api/v1/members/me/team-invitations/\(identifier)"
        
        let url = environment.configuration.serverURL + uri
        
        let http = self.createHTTP(.OpenIDJSON)
        
        http.DELETE(url) { (responseObject, error) in
            
            completion(error)
        }
    }
    
    func invitations(completion: (ErrorValue<Page<TeamInvitation>>) -> ()) {
        
        
    }
}
