//
//  DataUpdateRequest.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 8/8/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import AeroGearHttp
import AeroGearOAuth2
import JSON

public extension Store {
    
    func dataUpdates(_ summit: Identifier? = nil, latestDataUpdate: Identifier, limit: Int = 100, completion: @escaping (ErrorValue<[DataUpdate]>) -> ()) {
        
        let summitID: String
        
        if let identifier = summit {
            
            summitID = "\(identifier)"
            
        } else {
            
            summitID = "current"
        }
        
        let uri = "/api/v1/summits/" + summitID + "/entity-events?limit=\(limit)&last_event_id=\(latestDataUpdate)"
        
        dataUpdates(uri, completion: completion)
    }
    
    func dataUpdates(_ summit: Identifier? = nil, from date: Date, limit: Int = 50, completion: @escaping (ErrorValue<[DataUpdate]>) -> ()) {
        
        let summitID: String
        
        if let identifier = summit {
            
            summitID = "\(identifier)"
            
        } else {
            
            summitID = "current"
        }
        
        let uri = "/api/v1/summits/" + summitID + "/entity-events?limit=\(limit)&from_date=\(Int(date.timeIntervalSince1970))"
        
        dataUpdates(uri, completion: completion)
    }
}

// MARK: - Private

private extension Store {
    
    func dataUpdates(_ uri: String, completion: @escaping (ErrorValue<[DataUpdate]>) -> ()) {
        
        let url = environment.configuration.serverURL + uri
        
        let http = self.isLoggedIn ? self.createHTTP(.openIDJSON) : self.createHTTP(.serviceAccount)
        
        http.request(method: .get, path: url) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.error(error!)); return }
            
            // parse
            guard let json = try? JSON.Value(string: responseObject as! String),
                let jsonArray = json.arrayValue,
                let dataUpdates = DataUpdate.from(json: jsonArray)
                else { completion(.error(Error.invalidResponse)); return }
            
            completion(.value(dataUpdates))
        }
    }
}
