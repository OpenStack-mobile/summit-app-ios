//
//  AttendeeRequest.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/22/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation
import AeroGearHttp
import AeroGearOAuth2

public extension Store {
    
    func attendee(identifier: Int, completion: ErrorValue<SummitAttendee> -> ()) {
        
        let http = self.createHTTP(.ServiceAccount)
        
        let URI = "/api/v1/summits/current/attendees/" + "\(identifier)"
        
        let URL = Constants.Urls.ResourceServerBaseUrl + URI
        
        http.GET(URL) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.Error(error!)); return }
            
            guard let json = JSON.Value(string: responseObject as! String),
                let entity = SummitAttendee(JSONValue: json)
                else { completion(.Error(Error.InvalidResponse)); return }
            
            // success
            completion(.Value(entity))
        }
    }
}