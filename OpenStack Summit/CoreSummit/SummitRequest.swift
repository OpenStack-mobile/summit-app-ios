//
//  SummitRequest.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/14/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation
import AeroGearHttp

public extension Store {
    
    func summit(identifier: Int? = nil, completion: ErrorValue<Summit> -> ()) {
        
        let summitID: String
        
        if let identifier = identifier {
            
            summitID = "\(identifier)"
            
        } else {
            
            summitID = "current"
        }
        
        let URI = "/api/v1/summits/\(summitID)?expand=locations,sponsors,summit_types,event_types,presentation_categories,schedule"
        
        let http = self.createHTTP(.ServiceAccount)
        
        let url = Constants.Urls.ResourceServerBaseUrl + URI
        
        http.GET(url) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.Error(error!)); return }
            
            let foundationJSON = NSJSONSerialization.Value(rawValue: responseObject!)!
            let json = JSON.Value(foundation: foundationJSON)
            
            // parse
            guard let entity = Summit(JSONValue: json)
                else { completion(.Error(jsonError)); return }
            
            // success
            completion(.Value(entity))
        }
    }
}

private let jsonError = NSError(domain: "There was an error deserializing current summit", code: 6001, userInfo: nil)
