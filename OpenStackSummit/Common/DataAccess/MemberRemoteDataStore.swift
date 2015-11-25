//
//  MemberRemoteDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/28/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import SwiftyJSON
import AeroGearHttp
import AeroGearOAuth2

@objc
public protocol IMemberRemoteDataStore {
    func getLoggedInMember(completionBlock : (Member?, NSError?) -> Void)
}

public class MemberRemoteDataStore: NSObject, IMemberRemoteDataStore {
    var deserializerFactory: DeserializerFactory!
    var httpFactory: HttpFactory!
    
    public override init() {
        super.init()
    }
    
    public init(deserializerFactory: DeserializerFactory ) {
        self.deserializerFactory = deserializerFactory
    }
    
    public func getLoggedInMember(completionBlock : (Member?, NSError?) -> Void)  {
        let attendeeEndpoint = "https://testresource-server.openstack.org/api/v1/summits/current/attendees/me?expand=speaker,feedback"
        let http = httpFactory.create(HttpType.OpenIDGetFormUrlEncoded)
        http.GET(attendeeEndpoint, parameters: nil, completionHandler: {(responseObject, error) in
            if (error != nil) {
                completionBlock(nil, error)
                return
            }
            if let json = responseObject as? String {
                let deserializer = self.deserializerFactory.create(DeserializerFactoryType.Member)
                do {
                    let member = try deserializer.deserialize(json) as! Member                    
                    completionBlock(member, nil)
                }
                catch {
                    let innerError = NSError(domain: "There was an error deserializing my profile", code: 8001, userInfo: nil)
                    completionBlock(nil, innerError)
                }
            }
        })
    }
}
