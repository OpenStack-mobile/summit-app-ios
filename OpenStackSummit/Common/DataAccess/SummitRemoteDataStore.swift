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
    
    public func getActive(completionBlock : (Summit?, NSError?) -> Void) {
        let http = httpFactory.create(HttpType.ServiceAccount)
        
        http.GET("https://testresource-server.openstack.org/api/v1/summits/current?expand=locations,sponsors,summit_types,event_types,presentation_categories,schedule") {(responseObject, error) in
            if (error != nil) {
                completionBlock(nil, error)
                return
            }
            
            let json = responseObject as! String		
            var summit : Summit?
            var innerError: NSError?
            var deserializer : IDeserializer!
            
            deserializer = self.deserializerFactory.create(DeserializerFactoryType.Summit)

            do {
                summit = try deserializer.deserialize(json) as? Summit
            }
            catch {
                innerError = NSError(domain: "There was an error deserializing current summit", code: 6001, userInfo: nil)
            }
            
            completionBlock(summit, innerError)            
        }
    }
}
