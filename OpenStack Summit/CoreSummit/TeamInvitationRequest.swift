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
        
        let context = privateQueueManagedObjectContext
        
        http.PUT(url) { (responseObject, error) in
            
            if error == nil {
                
                try! context.performErrorBlockAndWait {
                    
                    guard let managedObject = try TeamInvitationManagedObject.find(identifier, context: context)
                        else { return }
                    
                    managedObject.accepted = true
                    
                    try context.save()
                }
            }
            
            // call completion block
            completion(error)
        }
    }
    
    func decline(invitation identifier: Identifier, completion: (ErrorType?) -> ()) {
        
        let uri = "/api/v1/members/me/team-invitations/\(identifier)"
        
        let url = environment.configuration.serverURL + uri
        
        let http = self.createHTTP(.OpenIDJSON)
        
        let context = privateQueueManagedObjectContext
        
        http.DELETE(url) { (responseObject, error) in
            
            if error == nil {
                
                try! context.performErrorBlockAndWait {
                    
                    guard let managedObject = try TeamInvitationManagedObject.find(identifier, context: context)
                        else { return }
                    
                    managedObject.accepted = false
                    
                    try context.save()
                }
            }
            
            // call completion block
            
            completion(error)
        }
    }
    
    func invitations(page: Int = 1,
                     perPage: Int = 10,
                     filter: ListTeamInvitations.Request.Filter? = nil,
                     completion: (ErrorValue<Page<ListTeamInvitations.Response.Invitation>>) -> ()) {
        
        let request = ListTeamInvitations.Request(filter: filter, page: page, perPage: perPage)
        
        let url = request.toURL(environment.configuration.serverURL)
        
        let http = self.createHTTP(.OpenIDJSON)
        
        let context = privateQueueManagedObjectContext
        
        http.GET(url) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.Error(error!)); return }
            
            guard let json = JSON.Value(string: responseObject as! String),
                let response = ListTeamInvitations.Response(JSONValue: json)
                else { completion(.Error(Error.InvalidResponse)); return }
            
            // cache
            try! context.performErrorBlockAndWait {
                
                try response.page.items.save(context)
                
                try context.save()
            }
            
            // success
            completion(.Value(response.page))
        }
    }
}

// MARK: - Supporting Types

public struct ListTeamInvitations {
    
    public struct Request {
        
        public enum Filter {
            
            case pending
            case accepted
        }
        
        public var filter: Filter?
        
        public var page: Int
        
        public var perPage: Int
        
        public func toURL(serverURL: String) -> String {
            
            let filterString: String
            
            if let filter = filter {
                
                switch filter {
                case .pending: filterString = "/pending"
                case .accepted: filterString = "/accepted"
                }
                
            } else {
                
                filterString = ""
            }
            
            let uri = "/api/v1/members/me/team-invitations\(filterString)?page=\(page)&per_page=\(perPage)&expand=team,invitee,inviter,groups"
            
            return serverURL + uri
        }
    }
    
    public struct Response {
        
        public struct Invitation: Unique {
            
            public let identifier: Identifier
            
            public let team: Team
            
            public let inviter: Member
            
            public let invitee: Member
            
            public let permission: TeamPermission
            
            public let created: Date
            
            public let updated: Date
            
            public let accepted: Bool
        }
        
        public let page: Page<Invitation>
    }
}

public func == (lhs: ListTeamInvitations.Response.Invitation, rhs: ListTeamInvitations.Response.Invitation) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.team == rhs.team
        && lhs.inviter == rhs.inviter
        && lhs.invitee == rhs.invitee
        && lhs.permission == rhs.permission
        && lhs.created == rhs.created
        && lhs.updated == rhs.updated
        && lhs.accepted == rhs.accepted
}

