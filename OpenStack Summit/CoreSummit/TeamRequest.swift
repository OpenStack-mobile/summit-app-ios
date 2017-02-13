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
    
    func create(team name: String, description: String?, completion: (ErrorValue<Team>) -> ()) {
        
        let uri = "/api/v1/teams"
        
        let url = environment.configuration.serverURL + uri
        
        let http = self.createHTTP(.OpenIDJSON)
        
        let context = privateQueueManagedObjectContext
        
        var jsonDictionary = [String: AnyObject]()
        
        jsonDictionary["name"] = name.toOpenStackEncoding()!
        
        if let description = description where description.isEmpty == false {
            jsonDictionary["description"] = description.toOpenStackEncoding()!
        }
        
        http.POST(url, parameters: jsonDictionary) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.Error(error!)); return }
            
            // parse
            guard let json = JSON.Value(string: responseObject as! String),
                let jsonObject = json.objectValue,
                let identifier = jsonObject["id"]?.rawValue as? Int
                else { completion(.Error(Error.InvalidResponse)); return }
            
            // cache
            try! context.performErrorBlockAndWait {
                
                guard let memberManagedObject = try self.authenticatedMember(context)
                    else { fatalError("Not authenticated") }
                
                // create team and cache
                let owner = Member(managedObject: memberManagedObject)
                
                let team = Team(identifier: identifier, name: name, descriptionText: description, created: Date(), updated: Date(), owner: owner, members: [], invitations: [])
                
                try team.save(context)
                
                try context.validateAndSave()
                
                // success
                completion(.Value(team))
            }
        }
    }
    
    func update(team identifier: Identifier, name: String, description: String? = nil, completion: (ErrorType?) -> ()) {
        
        let uri = "/api/v1/teams/\(identifier)"
        
        let url = environment.configuration.serverURL + uri
        
        let http = self.createHTTP(.OpenIDJSON)
        
        let context = privateQueueManagedObjectContext
        
        var jsonDictionary = [String: AnyObject]()
        
        jsonDictionary["name"] = name.toOpenStackEncoding()!
        
        if let description = description where description.isEmpty == false {
            jsonDictionary["description"] = description.toOpenStackEncoding()!
        }
        
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
                    
                    try context.validateAndSave()
                }
            }
            
            // success
            completion(nil)
        }
    }
    
    func fetch(team identifier: Identifier, completion: (ErrorValue<Team>) -> ()) {
        
        let uri = "/api/v1/teams/\(identifier)?expand=owner,members,member,groups"
        
        let url = environment.configuration.serverURL + uri
        
        let http = self.createHTTP(.OpenIDJSON)
        
        let context = privateQueueManagedObjectContext
        
        http.GET(url) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.Error(error!)); return }
            
            guard let json = JSON.Value(string: responseObject as! String),
                let entity = Team(JSONValue: json)
                else { completion(.Error(Error.InvalidResponse)); return }
            
            // cache
            try! context.performErrorBlockAndWait {
                
                try entity.save(context)
                
                try context.validateAndSave()
            }
            
            // success
            completion(.Value(entity))
        }
    }
    
    func delete(team identifier: Identifier, completion: (ErrorType?) -> ()) {
        
        let uri = "/api/v1/teams/\(identifier)"
        
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
                    
                    try context.validateAndSave()
                }
            }
            
            // success
            completion(nil)
        }
    }
    
    func teams(page page: Int = 1,
               perPage: Int = 10,
               completion: (ErrorValue<Page<Team>>) -> ()) {
        
        let urlComponents = NSURLComponents(string: environment.configuration.serverURL + "/api/v1/teams")!
        
        var queryItems = [NSURLQueryItem]()
        queryItems.append(NSURLQueryItem(name: "page", value: "\(page)"))
        queryItems.append(NSURLQueryItem(name: "per_page", value: "\(perPage)"))
        queryItems.append(NSURLQueryItem(name: "expand", value: "owner,members,member,groups"))
        urlComponents.queryItems = queryItems
        
        let url = urlComponents.URL!.absoluteString!
        
        let http = self.createHTTP(.OpenIDJSON)
        
        let context = privateQueueManagedObjectContext
        
        http.GET(url) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.Error(error!)); return }
            
            guard let json = JSON.Value(string: responseObject as! String),
                let page = Page<Team>(JSONValue: json)
                else { completion(.Error(Error.InvalidResponse)); return }
            
            // cache
            try! context.performErrorBlockAndWait {
                
                try page.items.save(context)
                
                try context.validateAndSave()
            }
            
            // success
            completion(.Value(page))
        }
    }
}
