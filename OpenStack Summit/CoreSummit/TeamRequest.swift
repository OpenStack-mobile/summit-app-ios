//
//  TeamRequest.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 12/29/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import AeroGearHttp
import AeroGearOAuth2
import JSON

public extension Store {
    
    func create(team name: String, description: String?, completion: @escaping (ErrorValue<Team>) -> ()) {
        
        let uri = "/api/v1/teams"
        
        let url = environment.configuration.serverURL + uri
        
        let http = self.createHTTP(.openIDJSON)
        
        let context = privateQueueManagedObjectContext
        
        var jsonDictionary = [String: Any]()
        
        jsonDictionary["name"] = name.toOpenStackEncoding()!
        
        if let description = description, description.isEmpty == false {
            jsonDictionary["description"] = description.toOpenStackEncoding()!
        }
        
        http.request(method: .post, path: url, parameters: jsonDictionary) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.error(error!)); return }
            
            // parse
            guard let json = try? JSON.Value(string: responseObject as! String),
                let jsonObject = json.objectValue,
                let identifier = jsonObject["id"]?.integerValue
                else { completion(.error(Error.invalidResponse)); return }
            
            // cache
            try! context.performErrorBlockAndWait {
                
                guard let memberManagedObject = try self.authenticatedMember(context)
                    else { fatalError("Not authenticated") }
                
                // create team and cache
                let owner = Member(managedObject: memberManagedObject)
                
                let team = Team(identifier: identifier, name: name, descriptionText: description, created: Date(), updated: Date(), owner: owner, members: [], invitations: [])
                
                let _ = try team.save(context)
                
                try context.validateAndSave()
                
                // success
                completion(.value(team))
            }
        }
    }
    
    func update(team identifier: Identifier, name: String, description: String? = nil, completion: @escaping (Swift.Error?) -> ()) {
        
        let uri = "/api/v1/teams/\(identifier)"
        
        let url = environment.configuration.serverURL + uri
        
        let http = self.createHTTP(.openIDJSON)
        
        let context = privateQueueManagedObjectContext
        
        var jsonDictionary = [String: Any]()
        
        jsonDictionary["name"] = name.toOpenStackEncoding()!
        
        if let description = description, description.isEmpty == false {
            jsonDictionary["description"] = description.toOpenStackEncoding()!
        }
        
        http.request(method: .put, path: url, parameters: jsonDictionary) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(error!); return }
            
            // update cache
            try! context.performErrorBlockAndWait {
                
                if let managedObject = try TeamManagedObject.find(identifier, context: context) {
                    
                    managedObject.name = name
                    
                    managedObject.descriptionText = description
                    
                    managedObject.updatedDate = Date()
                    
                    managedObject.didCache()
                    
                    try context.validateAndSave()
                }
            }
            
            // success
            completion(nil)
        }
    }
    
    func fetch(team identifier: Identifier, completion: @escaping (ErrorValue<Team>) -> ()) {
        
        let uri = "/api/v1/teams/\(identifier)?expand=owner,members,member,groups"
        
        let url = environment.configuration.serverURL + uri
        
        let http = self.createHTTP(.openIDJSON)
        
        let context = privateQueueManagedObjectContext
        
        http.request(method: .get, path: url) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.error(error!)); return }
            
            guard let json = try? JSON.Value(string: responseObject as! String),
                let entity = Team(json: json)
                else { completion(.error(Error.invalidResponse)); return }
            
            // cache
            try! context.performErrorBlockAndWait {
                
                let _ = try entity.save(context)
                
                try context.validateAndSave()
            }
            
            // success
            completion(.value(entity))
        }
    }
    
    func delete(team identifier: Identifier, completion: @escaping (Swift.Error?) -> ()) {
        
        let uri = "/api/v1/teams/\(identifier)"
        
        let url = environment.configuration.serverURL + uri
        
        let http = self.createHTTP(.openIDJSON)
        
        let context = privateQueueManagedObjectContext
        
        http.request(method: .delete, path: url) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(error!); return }
            
            // remove from cache
            try! context.performErrorBlockAndWait {
                
                if let managedObject = try TeamManagedObject.find(identifier, context: context) {
                    
                    context.delete(managedObject)
                    
                    try context.validateAndSave()
                }
            }
            
            // success
            completion(nil)
        }
    }
    
    func teams(page: Int = 1,
               perPage: Int = 10,
               completion: @escaping (ErrorValue<Page<Team>>) -> ()) {
        
        var urlComponents = URLComponents(string: environment.configuration.serverURL + "/api/v1/teams")!
        
        var queryItems = [URLQueryItem]()
        queryItems.append(URLQueryItem(name: "page", value: "\(page)"))
        queryItems.append(URLQueryItem(name: "per_page", value: "\(perPage)"))
        queryItems.append(URLQueryItem(name: "expand", value: "owner,members,member,groups"))
        urlComponents.queryItems = queryItems
        
        let url = urlComponents.url!.absoluteString
        
        let http = self.createHTTP(.openIDJSON)
        
        let context = privateQueueManagedObjectContext
        
        http.request(method: .get, path: url) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.error(error!)); return }
            
            guard let json = try? JSON.Value(string: responseObject as! String),
                let page = Page<Team>(json: json)
                else { completion(.error(Error.invalidResponse)); return }
            
            // cache
            try! context.performErrorBlockAndWait {
                
                let _ = try page.items.save(context)
                
                try context.validateAndSave()
            }
            
            // success
            completion(.value(page))
        }
    }
}
