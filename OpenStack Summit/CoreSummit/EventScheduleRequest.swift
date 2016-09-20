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
    
    func addEventToSchedule(summit: Identifier? = nil, event: Identifier, completion: (ErrorValue<()>) -> ()) {
        
        let summitID: String
        
        if let identifier = summit {
            
            summitID = "\(identifier)"
            
        } else {
            
            summitID = "current"
        }
        
        let URI = "/api/v1/summits/\(summitID)/attendees/me/schedule/\(event)"
        
        let URL = environment.configuration.serverURL + URI
        
        let http = self.createHTTP(.OpenIDGetFormUrlEncoded)
        
        http.POST(URL, parameters: nil, completionHandler: {(responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.Error(error!)); return }
            
            // cache
            if let attendee = self.authenticatedMember?.attendeeRole,
                let event = RealmSummitEvent.find(event, realm: self.realm) {
                
                try! self.realm.write {
                    
                    let index = attendee.scheduledEvents.indexOf("id = %@", event.id)
                    
                    if (index == nil) {
                        
                        attendee.scheduledEvents.append(event)
                    }
                    
                    completion(.Value())
                }
            }
        })
    }
    
    func removeEventFromSchedule(summit: Identifier? = nil, event: Identifier, completion: (ErrorValue<()>) -> ()) {
        
        let summitID: String
        
        if let identifier = summit {
            
            summitID = "\(identifier)"
            
        } else {
            
            summitID = "current"
        }
        
        let URI = "/api/v1/summits/\(summitID)/attendees/me/schedule/\(event)"
        
        let URL = environment.configuration.serverURL + URI
        
        let http = self.createHTTP(.OpenIDGetFormUrlEncoded)
        
        http.DELETE(URL, parameters: nil, completionHandler: {(responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.Error(error!)); return }
            
            // cache
            if let attendee = self.authenticatedMember?.attendeeRole,
                let event = RealmSummitEvent.find(event, realm: self.realm) {
                
                try! self.realm.write {
                    
                    if let index = attendee.scheduledEvents.indexOf("id = %@", event.id) {
                        
                        attendee.scheduledEvents.removeAtIndex(index)
                    }
                    
                    completion(.Value())
                }
            }
        })
    }
}
