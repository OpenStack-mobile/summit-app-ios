//
//  SummitRequest.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/14/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import AeroGearHttp
import AeroGearOAuth2
import JSON

public extension Store {
    #if MOCKED
    func summit(_ identifier: Identifier? = nil, completion: @escaping (ErrorValue<Summit>) -> ()) {
    
        let resourcePath = Bundle(for: Store.self).bundlePath + "/Summit7.json"
    
        let JSONString = try! String(contentsOfFile: resourcePath)
    
        let json = try! JSON.Value(string: JSONString)
    
        let summit = Summit(json: json)!
        
        let context = self.privateQueueManagedObjectContext
        
        // cache
        try! context.performErrorBlockAndWait {
            
            let managedObject = try summit.save(context)
            
            if let JSONObject = json.objectValue,
                let timeStamp = JSONObject["timestamp"]?.integerValue {
                
                managedObject.initialDataLoad = Date(timeIntervalSince1970: TimeInterval(timeStamp))
            }
            else {
                
                managedObject.initialDataLoad = Date()
            }
            
            try context.validateAndSave()
        }
    
        completion(.value(summit))
    }
    #else
    func summit(_ identifier: Identifier? = nil, completion: @escaping (ErrorValue<Summit>) -> ()) {
        
        let summitID: String
        
        if let identifier = identifier {
            
            summitID = "\(identifier)"
            
        } else {
            
            summitID = "current"
        }
        
        let uri = "/api/v1/summits/\(summitID)?expand=schedule"
        
        let http = self.createHTTP(.serviceAccount)
        
        let url = environment.configuration.serverURL + uri
        
        let context = privateQueueManagedObjectContext
        
        http.request(method: .get, path: url) { (responseObject, error) in
            
            guard error == nil
                else {
                    
                    if error?.code == 401 {
                        
                        // revoke and retry
                        http.authzModule?.revokeAccess { (responseObject, error) in
                            
                            guard error == nil
                                else { completion(.error(error!)); return }
                            
                            self.summit(identifier, completion: completion)
                        }
                    }
                    else {
                        
                        // forward error
                        completion(.error(error!))
                    }
                    
                    return
            }
            
            guard let json = try? JSON.Value(string: responseObject as! String),
                let summit = Summit(json: json)
                else { completion(.error(Error.invalidResponse)); return }
            
            // cache
            try! context.performErrorBlockAndWait {
                
                let managedObject = try summit.save(context)
                
                if let JSONObject = json.objectValue,
                    let timeStamp = JSONObject["timestamp"]?.integerValue {
                    
                    managedObject.initialDataLoad = Date(timeIntervalSince1970: TimeInterval(timeStamp))
                }
                else {
                    
                    managedObject.initialDataLoad = Date()
                }
                
                try context.validateAndSave()
            }
            
            self.currentMember(for: summit.identifier) { (response) in
                
                switch response {
                    
                case .error: break
                    
                case let .value(member):
                    
                    self.session.member = member.identifier
                    
                    NotificationCenter.default.post(name: Store.Notification.loggedIn, object: self)
                }
                
                completion(.value(summit))
            }
        }
    }
    #endif
}
