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
    
    func attendees(for ticketOrder: Int, summit: Identifier, completion: (ErrorValue<[NonConfirmedAttendee]>) -> ()) {
        
        let URI = "/api/v1/summits/\(summit)/external-orders/\(ticketOrder)"
        
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
    
    func confirmAttendee(for ticketOrder: Int, externalAttendee: Identifier, summit: Identifier, completion: (ErrorType?) -> ()) {
        
        let URI = "/api/v1/summits/\(summit)/external-orders/\(ticketOrder)/external-attendees/\(externalAttendee)/confirm"
        
        let URL = environment.configuration.serverURL + URI
        
        let http = self.createHTTP(.OpenIDGetFormUrlEncoded)
        
        http.POST(URL, parameters: nil, completionHandler: { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(error!); return }
            
            completion(nil)
        })
    }
}
