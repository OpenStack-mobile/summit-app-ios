//
//  NonConfirmedSummitAttendeeRequest.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 8/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation
import AeroGearHttp
import AeroGearOAuth2

public extension Store {
    
    func loggedInAttendee(summitIdentifier: Identifier? = nil, completion: (ErrorValue<String>) -> ()) {
        
        let summitID: String
        
        if let identifier = summitIdentifier {
            
            summitID = "\(identifier)"
            
        } else {
            
            summitID = "current"
        }
        
        let URI = "/api/v1/summits/" + summitID + "/members/me/"
        
        let URL = environment.configuration.authenticationURL + URI
        
        let http = self.createHTTP(.OpenIDGetFormUrlEncoded)
        
        http.GET(URL, parameters: nil, completionHandler: { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.Error(error!)); return }
            
            guard let json = JSON.Value(string: responseObject as! String),
                let name = json.objectValue?["name"]?.rawValue as? String
                else { completion(.Error(Error.InvalidResponse)); return }
            
            // success
            completion(.Value(name))
        })
    }
}