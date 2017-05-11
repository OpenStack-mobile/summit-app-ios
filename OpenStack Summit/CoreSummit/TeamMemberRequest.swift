//
//  TeamMemberRequest.swift
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
    
    func add(member memberIdentifier: Identifier,
             to team: Identifier,
             permission: TeamPermission = .read,
             completion: @escaping (ErrorValue<Identifier>) -> ()) {
        
        let uri = "/api/v1/teams/\(team)/members/\(memberIdentifier)"
        
        let url = environment.configuration.serverURL + uri
        
        let http = self.createHTTP(.openIDJSON)
        
        http.request(method: .post, path: url, parameters: ["permission": permission.rawValue]) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.error(error!)); return }
            
            guard let json = try? JSON.Value(string: responseObject as! String),
                let jsonObject = json.objectValue,
                let identifier = jsonObject["id"]?.integerValue
                else { completion(.error(Error.invalidResponse)); return }
            
            // success
            completion(.value(identifier))
        }
    }
    
    func remove(member identifier: Identifier, from team: Identifier, completion: @escaping (Swift.Error?) -> ()) {
        
        let uri = "/api/v1/teams/\(team)/members/\(identifier)"
        
        let url = environment.configuration.serverURL + uri
        
        let http = self.createHTTP(.openIDJSON)
        
        let context = privateQueueManagedObjectContext
        
        http.request(method: .delete, path: url) { (responseObject, error) in
            
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
