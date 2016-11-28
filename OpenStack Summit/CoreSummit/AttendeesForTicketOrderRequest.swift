//
//  AttendeesForTicketOrderRequest.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 8/3/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation
import AeroGearHttp
import AeroGearOAuth2

public extension Store {
    
    func attendees(for ticketOrder: String, summit: Identifier? = nil, completion: (ErrorValue<[NonConfirmedAttendee]>) -> ()) {
        
        let summitID: String
        
        if let identifier = summit {
            
            summitID = "\(identifier)"
            
        } else {
            
            summitID = "current"
        }
        
        let URI = "/api/v1/summits/" + summitID + "/external-orders/" + ticketOrder
        
        let URL = environment.configuration.serverURL + URI
        
        let http = self.createHTTP(.OpenIDGetFormUrlEncoded)
        
        http.GET(URL, parameters: nil, completionHandler: { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.Error(error!)); return }
            
            guard let json = JSON.Value(string: responseObject as! String)
                else { completion(.Error(Error.InvalidResponse)); return }
            
            guard let attendeesJSONArray = json.objectValue?["attendees"]?.arrayValue
                else { completion(.Value([])); return }
            
            guard let attendees = NonConfirmedAttendee.fromJSON(attendeesJSONArray)
                else { completion(.Error(Error.InvalidResponse)); return }
            
            // success
            completion(.Value(attendees))
        })
    }
}