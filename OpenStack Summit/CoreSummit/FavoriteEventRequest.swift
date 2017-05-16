//
//  FavoriteEventRequest.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/10/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import CoreData
import AeroGearHttp

public extension Store {
    
    func favorite(_ isFavorite: Bool = true, event: Identifier, summit: Identifier, completion: @escaping (Swift.Error?) -> ()) {
        
        let uri = "/api/v1/summits/\(summit)/members/me/favorites/\(event)"
        
        let url = environment.configuration.serverURL + uri
        
        let http = self.createHTTP(.openIDJSON)
        
        let context = privateQueueManagedObjectContext
        
        let httpMethod: HttpMethod = isFavorite ? .post : .delete
        
        http.request(method: httpMethod, path: url) { (responseObject, error) in
            
            if error == nil {
                
                try! context.performErrorBlockAndWait {
                    
                    guard let member = try self.authenticatedMember(context),
                        let event = try EventManagedObject.find(event, context: context)
                        else { return }
                    
                    if isFavorite {
                        
                        member.favoriteEvents.insert(event)
                        
                    } else {
                        
                        member.favoriteEvents.remove(event)
                    }
                    
                    try context.save()
                }
            }
            
            completion(error)
        }
    }
}
