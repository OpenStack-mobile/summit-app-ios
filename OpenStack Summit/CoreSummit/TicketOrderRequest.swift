//
//  AttendeesForTicketOrderRequest.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 8/3/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import AeroGearHttp
import AeroGearOAuth2

public extension Store {
    
    func attendees(for ticketOrder: Int, summit: Identifier, completion: (ErrorValue<[NonConfirmedAttendee]>) -> ()) {
        
        let URI = "/api/v1/summits/\(summit)/external-orders/\(ticketOrder)"
        
        let URL = environment.configuration.serverURL + URI
        
        let http = self.createHTTP(.openIDGetFormUrlEncoded)
        
        http.GET(URL, parameters: nil, completionHandler: { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.error(error!)); return }
            
            guard let json = try? JSON.Value(string: responseObject as! String)
                else { completion(.error(Error.invalidResponse)); return }
            
            guard let attendeesJSONArray = json.objectValue?["attendees"]?.arrayValue
                else { completion(.value([])); return }
            
            guard let attendees = NonConfirmedAttendee.from(json: attendeesJSONArray)
                else { completion(.error(Error.invalidResponse)); return }
            
            // success
            completion(.value(attendees))
        })
    }
    
    func confirmAttendee(for ticketOrder: Int, externalAttendee: Identifier, summit: Identifier, completion: (Swift.Error?) -> ()) {
        
        let URI = "/api/v1/summits/\(summit)/external-orders/\(ticketOrder)/external-attendees/\(externalAttendee)/confirm"
        
        let URL = environment.configuration.serverURL + URI
        
        let http = self.createHTTP(.openIDGetFormUrlEncoded)
        
        http.POST(URL, parameters: nil, completionHandler: { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(error!); return }
            
            completion(nil)
        })
    }
}
