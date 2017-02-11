//
//  FavoriteEventRequest.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/10/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import SwiftFoundation
import CoreData

public extension Store {
    
    func addFavorite(event event: Identifier, summit: Identifier, completion: (ErrorType?) -> ()) {
        
        let uri = "/api/v1/summits/\(summit)/members/me/favorites/\(event)"
        
        let url = environment.configuration.serverURL + uri
        
        let http = self.createHTTP(.OpenIDJSON)
        
        let context = privateQueueManagedObjectContext
        
        http.POST(url) { (responseObject, error) in
            
            if error == nil {
                
                try! context.performErrorBlockAndWait {
                    
                    
                    
                    try context.save()
                }
            }
            
            // call completion block
            completion(error)
        }
    }
    
    func removeFavorite(event event: Identifier, summit: Identifier, completion: (ErrorType?) -> ()) {
        
        let uri = "/api/v1/summits/\(summit)/members/me/favorites/\(event)"
        
        let url = environment.configuration.serverURL + uri
        
        let http = self.createHTTP(.OpenIDJSON)
        
        let context = privateQueueManagedObjectContext
        
        http.DELETE(url) { (responseObject, error) in
            
            if error == nil {
                
                try! context.performErrorBlockAndWait {
                    
                    
                    
                    try context.save()
                }
            }
            
            // call completion block
            completion(error)
        }
    }
}
