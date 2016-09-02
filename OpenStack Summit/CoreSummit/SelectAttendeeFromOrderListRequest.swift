//
//  SelectAttendeeFromOrderListRequest.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 8/3/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation
import RealmSwift
import AeroGearHttp
import AeroGearOAuth2

public extension Store {
    
    func selectAttendee(from orderList: String, externalAttendee: Identifier, summit: Identifier? = nil, completion: (ErrorValue<()>) -> ()) {
        
        let summitID: String
        
        if let identifier = summit {
            
            summitID = "\(identifier)"
            
        } else {
            
            summitID = "current"
        }
        
        let URI = "/api/v1/summits/" + summitID + "/external-orders/" + orderList + "/external-attendees/" + "\(externalAttendee)" + "/confirm"
        
        let URL = environment.configuration.serverURL + URI
        
        let http = self.createHTTP(.OpenIDGetFormUrlEncoded)
        
        http.POST(URL, parameters: nil, completionHandler: { (responseObject, error) in
            
            // forward error
            guard error == nil
                else { completion(.Error(error!)); return }
            
            completion(.Value())
        })
    }
}