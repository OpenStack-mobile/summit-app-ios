//
//  EventScheduleRequest.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/28/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation
import AeroGearHttp
import AeroGearOAuth2

public extension Store {
    
    func addEventToSchedule(summit: Identifier? = nil, event: Identifier, completion: (ErrorType?) -> ()) {
        
        let summitID: String
        
        if let identifier = summit {
            
            summitID = "\(identifier)"
            
        } else {
            
            summitID = "current"
        }
        
        let URI = "/api/v1/summits/\(summitID)/attendees/me/schedule/\(event)"
        
        let URL = environment.configuration.serverURL + URI
        
        let http = self.createHTTP(.OpenIDGetFormUrlEncoded)
        
        let context = privateQueueManagedObjectContext
        
        http.POST(URL, parameters: nil, completionHandler: {(responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(error!); return }
            
            // cache
            try! context.performErrorBlockAndWait {
                
                if let attendee = try self.authenticatedMember(context)?.attendeeRole,
                    let eventManagedObject = try EventManagedObject.find(event, context: context) {
                    
                    attendee.schedule.insert(eventManagedObject)
                    
                    try context.save()
                }
            }
            
            completion(nil)
        })
    }
    
    func removeEventFromSchedule(summit: Identifier? = nil, event: Identifier, completion: (ErrorType?) -> ()) {
        
        let summitID: String
        
        if let identifier = summit {
            
            summitID = "\(identifier)"
            
        } else {
            
            summitID = "current"
        }
        
        let URI = "/api/v1/summits/\(summitID)/attendees/me/schedule/\(event)"
        
        let URL = environment.configuration.serverURL + URI
        
        let http = self.createHTTP(.OpenIDGetFormUrlEncoded)
        
        let context = privateQueueManagedObjectContext
        
        http.DELETE(URL, parameters: nil, completionHandler: {(responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(error!); return }
            
            // cache
            try! context.performErrorBlockAndWait {
                                
                if let attendee = try self.authenticatedMember(context)?.attendeeRole,
                    let eventManagedObject = try EventManagedObject.find(event, context: context) {
                    
                    attendee.schedule.remove(eventManagedObject)
                    
                    try context.save()
                }
            }
            
            completion(nil)
        })
    }
}
