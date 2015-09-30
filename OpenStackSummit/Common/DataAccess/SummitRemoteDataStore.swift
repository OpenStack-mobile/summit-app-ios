//
//  SummitRemoteDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/14/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import AeroGearHttp
import AeroGearOAuth2

@objc
public protocol ISummitRemoteDataStore {
    func getActive(completionBlock : (Summit?, NSError?) -> Void)
}

public class SummitRemoteDataStore: NSObject, ISummitRemoteDataStore {
    var deserializerFactory: DeserializerFactory!
    var httpFactory: HttpFactory!
    var dataUpdatePoller: DataUpdatePoller!
    
    public func getActive(completionBlock : (Summit?, NSError?) -> Void) {
        let http = httpFactory.create(HttpType.ServiceAccount)
        
        http.GET("https://testresource-server.openstack.org/api/v1/summits/current?expand=locations,sponsors,summit_types,event_types,presentation_categories,schedule") {(responseObject, error) in
            if (error != nil) {
                completionBlock(nil, error)
                return
            }
                        
            let json = responseObject as! String
            let summit : Summit
            var deserializer : IDeserializer!
            
            deserializer = self.deserializerFactory.create(DeserializerFactoryType.Summit)
            summit = try! deserializer.deserialize(json) as! Summit

            completionBlock(summit, error)
            
            self.dataUpdatePoller.startPolling()
        }
    }
}
