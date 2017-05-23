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
import JSON

public extension Store {
    
    func addEventToSchedule(_ summit: Identifier? = nil, event: Identifier, completion: @escaping (Swift.Error?) -> ()) {
        
        let summitID: String
        
        if let identifier = summit {
            
            summitID = "\(identifier)"
            
        } else {
            
            summitID = "current"
        }
        
        let uri = "/api/v1/summits/\(summitID)/attendees/me/schedule/\(event)"
        
        let url = environment.configuration.serverURL + uri
        
        let http = self.createHTTP(.openIDGetFormUrlEncoded)
        
        let context = privateQueueManagedObjectContext
        
        http.request(method: .post, path: url) { (responseObject, error) in
            
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
        
        let uri = "/api/v1/summits/\(summitID)/attendees/me/schedule/\(event)"
        
        let url = environment.configuration.serverURL + uri
        
        let http = self.createHTTP(.openIDGetFormUrlEncoded)
        
        let context = privateQueueManagedObjectContext
        
        http.request(method: .delete, path: url) { (responseObject, error) in
            
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
        
        let uri = "/api/v1/summits/\(summitID)/attendees/me/schedule/\(event)/rsvp"
        
        let url = environment.configuration.serverURL + uri
        
        let http = self.createHTTP(.openIDGetFormUrlEncoded)
        
        let context = privateQueueManagedObjectContext
        
        http.request(method: .delete, path: url) { (responseObject, error) in
            
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
