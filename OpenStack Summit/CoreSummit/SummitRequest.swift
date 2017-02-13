//
//  SummitRequest.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/14/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation
import AeroGearHttp
import AeroGearOAuth2

public extension Store {
    #if MOCKED
    func summit(identifier: Identifier? = nil, completion: ErrorValue<Summit> -> ()) {
    
        let resourcePath = NSBundle(forClass: Store.self).bundlePath + "/Summit7.json"
    
        let JSONString = try! String(contentsOfFile: resourcePath)
    
        let json = JSON.Value(string: JSONString)!
    
        let summit = Summit(JSONValue: json)!
        
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
    func summit(identifier: Identifier? = nil, completion: ErrorValue<Summit> -> ()) {
        
        let summitID: String
        
        if let identifier = identifier {
            
            summitID = "\(identifier)"
            
        } else {
            
            summitID = "current"
        }
        
        let URI = "/api/v1/summits/\(summitID)?expand=schedule"
        
        let http = self.createHTTP(.ServiceAccount)
        
        let url = environment.configuration.serverURL + URI
        
        let context = privateQueueManagedObjectContext
        
        http.GET(url) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.Error(error!)); return }
            
            guard let json = JSON.Value(string: responseObject as! String),
                let summit = Summit(JSONValue: json)
                else { completion(.Error(Error.InvalidResponse)); return }
            
            // cache
            try! context.performErrorBlockAndWait {
                
                let managedObject = try summit.save(context)
                
                managedObject.initialDataLoad = NSDate()
                
                try context.validateAndSave()
            }
            
            // success
            completion(.Value(summit))
        }
    }
    #endif
}


