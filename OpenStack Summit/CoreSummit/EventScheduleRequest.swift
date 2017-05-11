//
//  EventScheduleRequest.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/28/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import AeroGearHttp
import AeroGearOAuth2

public extension Store {
    
    func addEventToSchedule(_ summit: Identifier? = nil, event: Identifier, completion: @escaping (Swift.Error?) -> ()) {
        
        let summitID: String
        
        if let identifier = summit {
            
            summitID = "\(identifier)"
            
        } else {
            
            summitID = "current"
        }
        
        let URI = "/api/v1/summits/\(summitID)/attendees/me/schedule/\(event)"
        
        let URL = environment.configuration.serverURL + URI
        
        let http = self.createHTTP(.openIDGetFormUrlEncoded)
        
        let context = privateQueueManagedObjectContext
        
        http.request(method: .post, path: URL) { (responseObject, error) in
            
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
        }
    }
    
    func removeEventFromSchedule(_ summit: Identifier? = nil, event: Identifier, completion: @escaping (Swift.Error?) -> ()) {
        
        let summitID: String
        
        if let identifier = summit {
            
            summitID = "\(identifier)"
            
        } else {
            
            summitID = "current"
        }
        
        let URI = "/api/v1/summits/\(summitID)/attendees/me/schedule/\(event)"
        
        let URL = environment.configuration.serverURL + URI
        
        let http = self.createHTTP(.openIDGetFormUrlEncoded)
        
        let context = privateQueueManagedObjectContext
        
        http.request(method: .delete, path: URL) { (responseObject, error) in
            
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
        }
    }
    
    func removeRSVP(_ summit: Identifier? = nil, event: Identifier, completion: @escaping (Swift.Error?) -> ()) {
        
        let summitID: String
        
        if let identifier = summit {
            
            summitID = "\(identifier)"
            
        } else {
            
            summitID = "current"
        }
        
        let URI = "/api/v1/summits/\(summitID)/attendees/me/schedule/\(event)/rsvp"
        
        let URL = environment.configuration.serverURL + URI
        
        let http = self.createHTTP(.openIDGetFormUrlEncoded)
        
        let context = privateQueueManagedObjectContext
        
        http.request(method: .delete, path: URL) { (responseObject, error) in
            
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
        }
    }
}
