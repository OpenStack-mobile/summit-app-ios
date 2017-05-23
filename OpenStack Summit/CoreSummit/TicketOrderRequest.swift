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
import JSON

public extension Store {
    
    func attendees(for ticketOrder: Int, summit: Identifier, completion: @escaping (ErrorValue<[NonConfirmedAttendee]>) -> ()) {
        
        let uri = "/api/v1/summits/\(summit)/external-orders/\(ticketOrder)"
        
        let url = environment.configuration.serverURL + uri
        
        let http = self.createHTTP(.openIDGetFormUrlEncoded)
        
        http.request(method: .get, path: url) { (responseObject, error) in
            
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
        }
    }
    
    func confirmAttendee(for ticketOrder: Int, externalAttendee: Identifier, summit: Identifier, completion: @escaping (Swift.Error?) -> ()) {
        
        let uri = "/api/v1/summits/\(summit)/external-orders/\(ticketOrder)/external-attendees/\(externalAttendee)/confirm"
        
        let url = environment.configuration.serverURL + uri
        
        let http = self.createHTTP(.openIDGetFormUrlEncoded)
        
        http.request(method: .post, path: url) { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(error!); return }
            
            completion(nil)
        }
    }
}
