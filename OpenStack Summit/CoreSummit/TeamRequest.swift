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
    
    func createTeam(name: String, description: String? = nil, completion: (ErrorValue<Team>) -> ()) {
        
        let URI = "api/v1/teams"
        
        let URL = environment.configuration.serverURL + URI
        
        let http = self.createHTTP(.OpenIDJSON)
        
        var jsonDictionary = [String: AnyObject]()
        jsonDictionary["name"] = name
        jsonDictionary["description"] = description
        
        let context = privateQueueManagedObjectContext
        
        http.POST(URL, parameters: jsonDictionary) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.Error(error!)); return }
            
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
}
