//
//  DataUpdateRequest.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 8/8/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation
import RealmSwift
import AeroGearHttp
import AeroGearOAuth2

public extension Store {
    
    func dataUpdate(summit: Identifier? = nil, latestDataUpdate: Identifier, limit: Int = 100, completion: (ErrorValue<[DataUpdate]>) -> ()) {
        
        let summitID: String
        
        if let identifier = summit {
            
            summitID = "\(identifier)"
            
        } else {
            
            summitID = "current"
        }
        
        let URI = "/api/v1/summits/" + summitID + "/entity-events?limit=\(limit)&last_event_id=\(latestDataUpdate)"
        
        dataUpdate(URI, completion: completion)
    }
    
    func dataUpdate(summit: Identifier? = nil, from date: Date, limit: Int = 50, completion: (ErrorValue<[DataUpdate]>) -> ()) {
        
        let summitID: String
        
        if let identifier = summit {
            
            summitID = "\(identifier)"
            
        } else {
            
            summitID = "current"
        }
        
        let URI = "/api/v1/summits/" + summitID + "/entity-events?limit=\(limit)&from_date=\(Int(date.timeIntervalSince1970))"
        
        dataUpdate(URI, completion: completion)
    }
}

// MARK: - Private

private extension Store {
    
    func dataUpdate(URI: String, completion: (ErrorValue<[DataUpdate]>) -> ()) {
        
        let URL = configuration[.ServerURL] + URI
        
        let http = self.isLoggedIn ? self.createHTTP(.OpenIDJSON) : self.createHTTP(.ServiceAccount)
        
        http.GET(URL) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.Error(error!)); return }
            
            // parse
            guard let json = JSON.Value(string: responseObject as! String),
                let jsonArray = json.arrayValue,
                let dataUpdates = DataUpdate.fromJSON(jsonArray)
                else { completion(.Error(Error.InvalidResponse)); return }
            
            completion(.Value(dataUpdates))
        }
    }
}
