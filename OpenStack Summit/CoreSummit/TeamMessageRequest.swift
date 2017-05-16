//
//  TeamMessageRequest.swift
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
    
    func send(_ message: String, to team: Identifier, priority: TeamMessage.Priority = .normal, completion: @escaping (ErrorValue<TeamMessage>) -> ()) {
        
        let uri = "/api/v1/teams/\(team)/messages"
        
        let url = environment.configuration.serverURL + uri
        
        let http = self.createHTTP(.openIDJSON)
        
        let context = privateQueueManagedObjectContext
        
        guard let member = self.authenticatedMember?.id
            else { fatalError("Must be logged in") }
        
        let messageASCII = message.toOpenStackEncoding()!
        
        http.request(method: .post, path: url, parameters: ["body": messageASCII, "priority": priority.rawValue]) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.error(error!)); return }
            
            guard let json = try? JSON.Value(string: responseObject as! String),
                let jsonObject = json.objectValue,
                let identifier = jsonObject["id"]?.integerValue
                else { completion(.error(Error.invalidResponse)); return }
            
            let message = TeamMessage(identifier: identifier, team: .identifier(team), body: message, created: Date(), from: .identifier(member))
            
            // cache
            try! context.performErrorBlockAndWait {
                
                let _ = try message.save(context)
                
                try context.validateAndSave()
            }
            
            // success
            completion(.value(message))
        }
    }
}

// MARK: - Supporting Types

public extension TeamMessage {
    
    public enum Priority: String {
        
        case normal = "NORMAL"
        case high   = "HIGH"
        
        public init() { self = .normal }
    }
}
