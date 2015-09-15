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
}

public class LoginInteractor: NSObject {
    func login(completionBlock: (NSError?) -> Void) {
        var session: ISession
        
        let kAccessToken = "access_token"
        
        func login() {
            let http = Http()
            let config = Config(
                base: "https://dev-identity-provider",
                authzEndpoint: "oauth2/auth",
                redirectURL: "org.openstack.ios.openstack-summit://oauthCallback",
                accessTokenEndpoint: "oauth2/token",
                clientId: "OpenID Client ID",
                revokeTokenEndpoint: "oauth2/token/revoke",
                isOpenIDConnect: true,
                userInfoEndpoint: "api/v1/users/info",
                scopes: ["openid", "https://dev-resource-server/summits/read"],
                clientSecret: "OpenID Secret"
            )
            
            let oauth2Module = AccountManager.addAccount(config, moduleClass: KeycloakOAuth2Module.self)
            http.authzModule = oauth2Module
            oauth2Module.login {(accessToken: AnyObject?, claims: OpenIDClaim?, error: NSError?) in // [1]
                session.set(kAccessToken, value: accessToken)
                // Do your own stuff here
            }
        }
    }
}
