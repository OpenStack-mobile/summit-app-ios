//
//  ListMembersRequest.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 12/28/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation
import AeroGearHttp
import AeroGearOAuth2

public extension Store {
    
    func members(filter: String? = nil, page: Int = 1, perPage: Int = 10, completion: (ErrorValue<Page<Member>>) -> ()) {
        
        var URI = "/api/v1/members?page=\(page)&per_page=\(perPage)"
        
        if let filterString = filter {
            
            URI += "&filter=" + filterString
        }
        
        let URL = environment.configuration.serverURL + URI
        
        let http = self.createHTTP(.ServiceAccount)
        
        let context = privateQueueManagedObjectContext
        
        http.GET(URL) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.Error(error!)); return }
            
            guard let json = JSON.Value(string: responseObject as! String),
                let page = Page<Member>(JSONValue: json)
                else { completion(.Error(Error.InvalidResponse)); return }
            
            // cache
            try! context.performErrorBlockAndWait { try page.items.save(context) }
            
            // success
            completion(.Value(page))
        }
    }
}
