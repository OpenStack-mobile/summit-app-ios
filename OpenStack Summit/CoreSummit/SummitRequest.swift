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
    
    func summit(identifier: Identifier? = nil, completion: ErrorValue<Summit> -> ()) {
        
        let summitID: String
        
        if let identifier = identifier {
            
            summitID = "\(identifier)"
            
        } else {
            
            summitID = "current"
        }
        
        let URI = "/api/v1/summits/\(summitID)?expand=locations,sponsors,summit_types,event_types,presentation_categories,schedule"
        
        let http = self.createHTTP(.ServiceAccount)
        
        let url = environment.configuration.serverURL + URI
        
        http.GET(url) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.Error(error!)); return }
            
            guard let json = JSON.Value(string: responseObject as! String),
                let entity = Summit(JSONValue: json)
                else { completion(.Error(Error.InvalidResponse)); return }
            
            // cache
            #if CORESUMMITREALM
            try! self.realm.write {
                
                let realmSummit = entity.save(self.realm)
                
                realmSummit.initialDataLoadDate = NSDate()
            }
            #else
            self.cache = entity
            try! (responseObject as! String).writeToURL(Store.cacheURL, atomically: true, encoding: NSUTF8StringEncoding)
            #endif
            
            // success
            completion(.Value(entity))
        }
    }
}
