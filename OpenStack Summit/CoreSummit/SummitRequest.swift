//
//  SummitRequest.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/14/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

public extension Store {
    
    func summit(identifier: Int? = nil, completion: ErrorValue<Summit> -> ()) {
        
        let summitID: String
        
        if let identifier = identifier {
            
            summitID = "\(identifier)"
            
        } else {
            
            summitID = "current"
        }
        
        let URI = "/api/v1/summits/\(summitID)?expand=locations,sponsors,summit_types,event_types,presentation_categories,schedule"
        
        let request = HTTP.Request(URL: serverURL + URI)
        
        getEntity(request) { completion($0) }
    }
}