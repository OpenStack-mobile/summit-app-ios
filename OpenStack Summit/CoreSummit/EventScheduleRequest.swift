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
    
    func addEventToSchedule(summit: Identifier? = nil, attendee: Identifier, event: Identifier, completion: (ErrorValue<()>) -> ()) {
        
        let summitID: String
        
        if let identifier = summit {
            
            summitID = "\(identifier)"
            
        } else {
            
            summitID = "current"
        }
        
        let URI = "/api/v1/summits/\(summitID)/attendees/\(attendee)/schedule/\(event)"
        
        let URL = Constants.Urls.ResourceServerBaseUrl + URI
        
        let http = self.createHTTP(.OpenIDGetFormUrlEncoded)
        
        http.POST(URL, parameters: nil, completionHandler: {(responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.Error(error!)); return }
            
            // cache
            if let attendee = RealmSummitAttendee.find(attendee, realm: self.realm),
                let event = RealmSummitEvent.find(event, realm: self.realm) {
                
                try! self.realm.write {
                    
                    let index = attendee.scheduledEvents.indexOf("id = %@", event.id)
                    
                    if (index == nil) {
                        
                        attendee.scheduledEvents.append(event)
                    }
                }
            }
        })
    }
    
    func removeEventFromSchedule(attendee: Identifier, event: Identifier, completion: (ErrorValue<()>) -> ()) {
        
        let URI = "/api/v1/summits/current/attendees/\(attendee)/schedule/\(event)"
        
        let URL = Constants.Urls.ResourceServerBaseUrl + URI
        
        let http = self.createHTTP(.OpenIDGetFormUrlEncoded)
        
        http.DELETE(URL, parameters: nil, completionHandler: {(responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.Error(error!)); return }
            
            // cache
            if let attendee = RealmSummitAttendee.find(attendee, realm: self.realm),
                let event = RealmSummitEvent.find(event, realm: self.realm) {
                
                try! self.realm.write {
                    
                    if let index = attendee.scheduledEvents.indexOf("id = %@", event.id) {
                        
                        attendee.scheduledEvents.removeAtIndex(index)
                    }
                }
            }
        })
    }
}
