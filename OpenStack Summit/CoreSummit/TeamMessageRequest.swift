//
//  TeamMessageRequest.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 12/29/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation
import AeroGearHttp
import AeroGearOAuth2

public extension Store {
    
    func send(message: String, to team: Identifier, priority: TeamMessage.Priority = .normal, completion: (ErrorValue<TeamMessage>) -> ()) {
        
        let uri = "/api/v1/teams/\(team)/messages"
        
        let url = environment.configuration.serverURL + uri
        
        let http = self.createHTTP(.OpenIDJSON)
        
        let context = privateQueueManagedObjectContext
        
        guard let member = self.authenticatedMember?.identifier
            else { fatalError("Must be logged in") }
        
        let messageASCII = message.toOpenStackEncoding()!
        
        http.POST(url, parameters: ["body": messageASCII, "priority": priority.rawValue]) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.Error(error!)); return }
            
            guard let json = JSON.Value(string: responseObject as! String),
                let jsonObject = json.objectValue,
                let identifier = jsonObject["id"]?.rawValue as? Int
                else { completion(.Error(Error.InvalidResponse)); return }
            
            let message = TeamMessage(identifier: identifier, team: .identifier(team), body: message, created: Date(), from: .identifier(member))
            
            // cache
            try! context.performErrorBlockAndWait {
                
                try message.save(context)
                
                try context.save()
            }
            
            // success
            completion(.Value(message))
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
