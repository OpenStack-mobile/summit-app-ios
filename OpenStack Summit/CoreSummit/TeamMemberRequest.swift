//
//  TeamMemberRequest.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 12/29/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation
import AeroGearHttp
import AeroGearOAuth2

public extension Store {
    
    func add(member memberIdentifier: Identifier, to team: Identifier, permission: TeamPermission = .read, completion: (ErrorValue<Identifier>) -> ()) {
        
        let uri = "/api/v1/teams/\(team)/members/\(memberIdentifier)"
        
        let url = environment.configuration.serverURL + uri
        
        let http = self.createHTTP(.openIDJSON)
        
        http.POST(url, parameters: ["permission": permission.rawValue]) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.error(error!)); return }
            
            guard let json = JSON.Value(string: responseObject as! String),
                let jsonObject = json.objectValue,
                let identifier = jsonObject["id"]?.rawValue as? Int
                else { completion(.error(Error.invalidResponse)); return }
            
            // success
            completion(.value(identifier))
        }
    }
    
    func remove(member identifier: Identifier, from team: Identifier, completion: (ErrorProtocol?) -> ()) {
        
        let uri = "/api/v1/teams/\(team)/members/\(identifier)"
        
        let url = environment.configuration.serverURL + uri
        
        let http = self.createHTTP(.openIDJSON)
        
        let context = privateQueueManagedObjectContext
        
        http.DELETE(url) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(error!); return }
            
            // remove from cache
            try! context.performErrorBlockAndWait {
                
                if let managedObject = try TeamMemberManagedObject.find(identifier, context: context) {
                    
                    context.delete(managedObject)
                    
                    try context.validateAndSave()
                }
            }
            
            // success
            completion(nil)
        }
    }
}
