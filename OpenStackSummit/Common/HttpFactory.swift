//
//  HttpFactory.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/26/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import AeroGearHttp
import AeroGearOAuth2

@objc public enum HttpType: Int {
    case OpenID, ServiceAccount
}

public class HttpFactory: NSObject {
    var securityManager: SecurityManager!
    
    public func create(type: HttpType) -> Http {
        let http = Http(responseSerializer: StringResponseSerializer())
        
        if (type == HttpType.OpenID) {
            http.authzModule = securityManager.oauthModuleOpenID
        }
        else {
            http.authzModule = securityManager.oauthModuleServiceAccount
        }
        return http
    }
}
