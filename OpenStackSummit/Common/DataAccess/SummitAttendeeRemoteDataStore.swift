//
//  SummitAttendeeRemoteDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/5/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public class SummitAttendeeRemoteDataStore: NSObject {
    var deserializerFactory: DeserializerFactory!
    var httpFactory: HttpFactory!
    
    public func getByFilter(searchTerm: String, page: Int, recordsPerPage: Int, completionBlock : ([PresentationSpeaker]?, NSError?) -> Void) {
        let http = httpFactory.create(HttpType.ServiceAccount)
        
        http.GET("https://testresource-server.openstack.org/api/v1/summits/current/speakers") {(responseObject, error) in
            if (error != nil) {
                completionBlock(nil, error)
                return
            }
            
            let json = responseObject as! String
            var deserializer : IDeserializer!
            
            deserializer = self.deserializerFactory.create(DeserializerFactoryType.PresentationSpeaker)
            let speakers = try! deserializer.deserializePage(json) as! [PresentationSpeaker]
            
            completionBlock(speakers, error)
        }
    }
}
