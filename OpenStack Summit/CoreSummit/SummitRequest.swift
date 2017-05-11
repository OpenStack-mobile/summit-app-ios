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
    func summit(identifier: Identifier? = nil, completion: ErrorValue<Summit> -> ()) {
    
        let resourcePath = NSBundle(forClass: Store.self).bundlePath + "/Summit7.json"
    
        let JSONString = try! String(contentsOfFile: resourcePath)
    
        let json = try? JSON.Value(string: JSONString)!
    
        let summit = Summit(json: json)!
        
        let context = self.privateQueueManagedObjectContext
        
        // cache
        try! context.performErrorBlockAndWait {
            
            let managedObject = try summit.save(context)
            
            managedObject.initialDataLoad = NSDate()
            
            try context.validateAndSave()
        }
    
        completion(.Value(summit))
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
            
            // forward error
            guard error == nil
                else { completion(.error(error!)); return }
            
            guard let json = try? JSON.Value(string: responseObject as! String),
                let summit = Summit(json: json)
                else { completion(.error(Error.invalidResponse)); return }
            
            // cache
            try! context.performErrorBlockAndWait {
                
                let managedObject = try summit.save(context)
                
                managedObject.initialDataLoad = Date()
                
                try context.validateAndSave()
            }
            
            // success
            completion(.value(summit))
        }
    }
    #endif
}


