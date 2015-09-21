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
import SwiftyJSON
import RealmSwift

@objc
public protocol ISummitRemoteDataStore {
    func getActive(completionBlock : (Summit?, NSError?) -> Void)
}

public class SummitRemoteDataStore: NSObject, ISummitRemoteDataStore {
    var deserializerFactory: DeserializerFactory!
    var securityManager: SecurityManager!
    
    public func getActive(completionBlock : (Summit?, NSError?) -> Void) {
        let http = Http(responseSerializer: StringResponseSerializer())
        http.authzModule = securityManager.oauthModuleServiceAccount
        
        http.GET("https://testresource-server.openstack.org/api/v1/summits/current?expand=locations,sponsors,summit_types,event_types,presentation_categories,schedule") {(responseObject, error) in
            if (error != nil) {
                completionBlock(nil, error)
                return
            }
                        
            let json = responseObject as! NSString
            let data = json.dataUsingEncoding(NSUTF8StringEncoding)
            let jsonObject = JSON(data: data!)
            let summit : Summit
            var deserializer : IDeserializer!
            
            deserializer = self.deserializerFactory.create(DeserializerFactories.Summit)
            summit = try! deserializer.deserialize(jsonObject) as! Summit

            completionBlock(summit, error)
        }
    }
}
