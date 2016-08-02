//
//  NonConfirmedSummitAttendeeRequest.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 8/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation
import RealmSwift
import AeroGearHttp
import AeroGearOAuth2

public extension Store {
    
    func loggedInAttendee(completion: (ErrorValue<String>) -> ()) {
        
        let URI = "/api/v1/users/me"
        
        let URL = configuration[.AuthenticationURL] + URI
        
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