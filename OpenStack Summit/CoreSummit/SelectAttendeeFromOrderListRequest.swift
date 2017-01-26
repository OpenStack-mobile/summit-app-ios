//
//  SelectAttendeeFromOrderListRequest.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 8/3/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation
import AeroGearHttp
import AeroGearOAuth2

public extension Store {
    
    func selectAttendee(from orderList: String, externalAttendee: Identifier, summit: Identifier, completion: (ErrorType?) -> ()) {
        
        let URI = "/api/v1/summits/\(summit)/external-orders/" + orderList + "/external-attendees/" + "\(externalAttendee)" + "/confirm"
        
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
