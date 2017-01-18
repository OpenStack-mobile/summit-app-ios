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
        
        let uri = "/api/v1/members/me/team-invitations/\(identifier)"
        
        let url = environment.configuration.serverURL + uri
        
        let http = self.createHTTP(.OpenIDJSON)
        
        http.PUT(url) { (responseObject, error) in
            
            completion(error)
        }
    }
    
    func decline(invitation identifier: Identifier, completion: (ErrorType?) -> ()) {
        
        let uri = "/api/v1/members/me/team-invitations/\(identifier)"
        
        let url = environment.configuration.serverURL + uri
        
        let http = self.createHTTP(.OpenIDJSON)
        
        http.DELETE(url) { (responseObject, error) in
            
            completion(error)
        }
    }
    
    func invitations(page: Int = 1, perPage: Int = 10, filter: InvitationsFilter? = nil, completion: (ErrorValue<Page<TeamInvitation>>) -> ()) {
        
        let filterString: String
        
        if let filter = filter {
            
            switch filter {
            case .pending: filterString = "/pending"
            case .accepted: filterString = "/accepted"
            }
            
        } else {
            
            filterString = ""
        }
        
        let uri = "/api/v1/members/me/team-invitations\(filterString)?page=\(page)&per_page=\(perPage)&expand=team,invitee,inviter"
        
        let url = environment.configuration.serverURL + uri
        
        let http = self.createHTTP(.OpenIDJSON)
        
        let context = privateQueueManagedObjectContext
        
        http.GET(url) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.Error(error!)); return }
            
            guard let json = JSON.Value(string: responseObject as! String),
                let page = Page<TeamInvitation>(JSONValue: json)
                else { completion(.Error(Error.InvalidResponse)); return }
            
            // cache
            try! context.performErrorBlockAndWait {
                
                try page.items.save(context)
                
                try context.save()
            }
            
            // success
            completion(.Value(page))
        }
    }
}

// MARK: - Supporting Types

public enum InvitationsFilter {
    
    case pending
    case accepted
}

