//
//  TeamRequest.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 12/29/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation
import AeroGearHttp
import AeroGearOAuth2

public extension Store {
    
    func create(team name: String, description: String? = nil, completion: (ErrorValue<Team>) -> ()) {
        
        let URI = "api/v1/teams"
        
        let URL = environment.configuration.serverURL + URI
        
        let http = self.createHTTP(.OpenIDJSON)
        
        let context = privateQueueManagedObjectContext
        
        var jsonDictionary = [String: AnyObject]()
        jsonDictionary["name"] = name
        jsonDictionary["description"] = description
        
        http.POST(URL, parameters: jsonDictionary) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.Error(error!)); return }
            
            // parse
            guard let json = JSON.Value(string: responseObject as! String),
                let jsonObject = json.objectValue,
                let identifier = jsonObject["id"]?.rawValue as? Int
                else { completion(.Error(Error.InvalidResponse)); return }
            
            // cache
            context.performBlock {
                
                guard let memberManagedObject = try! self.authenticatedMember(context)
                    else { fatalError("Not authenticated") }
                
                // create team and cache
                let member = Member(managedObject: memberManagedObject)
                
                let owner = TeamMember(team: identifier, member: member, permission: .admin, membership: .owner)
                
                let team = Team(identifier: identifier, name: name, descriptionText: description, created: Date(), updated: Date(), owner: owner, members: [])
                
                try! team.save(context)
                
                // success
                completion(.Value(team))
            }
        }
    }
    
    func update(team identifier: Identifier, name: String, description: String? = nil, completion: (ErrorType?) -> ()) {
        
        let uri = "api/v1/teams/\(identifier)"
        
        let url = environment.configuration.serverURL + uri
        
        let http = self.createHTTP(.OpenIDJSON)
        
        let context = privateQueueManagedObjectContext
        
        var jsonDictionary = [String: AnyObject]()
        jsonDictionary["name"] = name
        jsonDictionary["description"] = description
        
        http.PUT(url, parameters: jsonDictionary)  { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(error!); return }
            
            // update cache
            try! context.performErrorBlockAndWait {
                
                if let managedObject = try TeamManagedObject.find(identifier, context: context) {
                    
                    managedObject.name = name
                    
                    managedObject.descriptionText = description
                    
                    managedObject.updatedDate = NSDate()
                    
                    managedObject.didCache()
                    
                    try context.save()
                }
            }
            
            // success
            completion(nil)
        }
    }
    
    func fetch(team identifier: Identifier, completion: (ErrorValue<Team>) -> ()) {
        
        let URI = "api/v1/teams/\(identifier)"
        
        let URL = environment.configuration.serverURL + URI
        
        let http = self.createHTTP(.ServiceAccount)
        
        let context = privateQueueManagedObjectContext
        
        http.GET(URL) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.Error(error!)); return }
            
            guard let json = JSON.Value(string: responseObject as! String),
                let entity = Team(JSONValue: json)
                else { completion(.Error(Error.InvalidResponse)); return }
            
            // cache
            try! context.performErrorBlockAndWait { try entity.save(context) }
            
            // success
            completion(.Value(entity))
        }
    }
    
    func delete(team identifier: Identifier, completion: (ErrorType?) -> ()) {
        
        let uri = "api/v1/teams/\(identifier)"
        
        let url = environment.configuration.serverURL + uri
        
        let http = self.createHTTP(.OpenIDJSON)
        
        let context = privateQueueManagedObjectContext
        
        http.DELETE(url) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(error!); return }
            
            // remove from cache
            try! context.performErrorBlockAndWait {
                
                if let managedObject = try TeamManagedObject.find(identifier, context: context) {
                    
                    context.deleteObject(managedObject)
                    
                    try context.save()
                }
            }
            
            // success
            completion(nil)
        }
    }
    
    /*
    func add(member memberIdentifier: Identifier, to team: Identifier, permission: TeamPermission = .read, completion: (ErrorValue<TeamMember>) -> ()) {
        
        let uri = "api/v1/teams/\(team)/members/\(memberIdentifier)"
        
        let url = environment.configuration.serverURL + uri
        
        let http = self.createHTTP(.OpenIDJSON)
        
        let context = privateQueueManagedObjectContext
        
        http.POST(url, parameters: ["permissions": permission.rawValue]) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.Error(error!)); return }
            
            guard let json = JSON.Value(string: responseObject as! String),
                let jsonObject = json.objectValue,
                let identifier = jsonObject["id"]?.rawValue as? Int
                else { completion(.Error(Error.InvalidResponse)); return }
            
            
        }
    }*/
    
    func remove(member memberIdentifier: Identifier, from team: Identifier, completion: (ErrorType?) -> ()) {
        
        let uri = "api/v1/teams/\(team)/members/\(memberIdentifier)"
        
        let url = environment.configuration.serverURL + uri
        
        let http = self.createHTTP(.OpenIDJSON)
        
        let context = privateQueueManagedObjectContext
        
        http.DELETE(url) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(error!); return }
            
            // remove from cache
            try! context.performErrorBlockAndWait {
                
                if let managedObject = try TeamMemberManagedObject.find(team: team, member: memberIdentifier, context: context) {
                    
                    context.deleteObject(managedObject)
                    
                    try context.save()
                }
            }
            
            // success
            completion(nil)
        }
    }
}
