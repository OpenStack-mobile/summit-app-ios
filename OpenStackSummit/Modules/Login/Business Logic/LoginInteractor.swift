//
//  LoginInteractor.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/7/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import AeroGearOAuth2
import AeroGearHttp

@objc
public protocol ILoginInteractor {
    func login(completionBlock: (NSError?) -> Void)
    func logout(completionBlock: (NSError?) -> Void)
}

public class LoginInteractor: NSObject {
    var securityManager: SecurityManager!
    var session: ISession!
    let kAccessToken = "access_token"
    
    func login(completionBlock: (NSError?) -> Void) {
        
        securityManager.oauthModuleOpenID.login {(accessToken: AnyObject?, claims: OpenIDClaim?, error: NSError?) in // [1]
            self.session.set(self.kAccessToken, value: accessToken)
            // Do your own stuff here
        }
    }
    
    func logout(completionBlock: (NSError?) -> Void) {
        securityManager.oauthModuleOpenID.revokeAccess() { (response, error) in // [1]
            self.session.set(self.kAccessToken, value: nil)
            // Do your own stuff here
        }
    }
}
