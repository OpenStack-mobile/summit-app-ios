//
//  SecurityManager.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/16/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import AeroGearHttp
import AeroGearOAuth2

public class SecurityManager: NSObject {
    var session : ISession!
    var oauthModuleOpenID: OAuth2Module!
    var oauthModuleServiceAccount: OAuth2Module!
    var currentMember: Member?
    var memberRemoteDataStore: IMemberRemoteDataStore! // TODO: this should be weak to avoid retain loop
    let kCurrentMember = "currentMember"
    
    
    public override init() {
        var config = Config(
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
        
        oauthModuleOpenID = AccountManager.addAccount(config, moduleClass: OpenStackOAuth2Module.self)

        config = Config(
            base: "https://dev-identity-provider",
            authzEndpoint: "oauth2/auth",
            redirectURL: "org.openstack.ios.openstack-summit://oauthCallback",
            accessTokenEndpoint: "oauth2/token",
            clientId: "Service Account Client ID",
            revokeTokenEndpoint: "oauth2/token/revoke",
            isServiceAccount: true,
            userInfoEndpoint: "api/v1/users/info",
            scopes: ["https://dev-resource-server/summits/read"],
            clientSecret: "Service Account Secret"
        )
        
        oauthModuleServiceAccount = AccountManager.addAccount(config, moduleClass: OpenStackOAuth2Module.self)
    }
    
    public func login(completionBlock: (NSError?) -> Void) {
        
        oauthModuleOpenID.login {(accessToken: AnyObject?, claims: OpenIDClaim?, error: NSError?) in // [1]
            if (error != nil) {
                completionBlock(error)
                return
            }
            
            if (accessToken == nil) {
                return
            }
            
            self.memberRemoteDataStore.getLoggedInMember() { (member, error) in
                self.currentMember = member
                completionBlock(error)
            }
        }
    }
    
    public func logout(completionBlock: (NSError?) -> Void) {
        oauthModuleOpenID.revokeAccess() { (response, error) in // [1]
            self.currentMember = nil
            completionBlock(error)
        }
    }
    
    public func getCurrentMemberRole() -> MemberRoles{
        
        var role = MemberRoles.Anonymous
        if (currentMember != nil) {
            if (currentMember?.speakerRole != nil) {
                role = MemberRoles.Speaker
            }
            else if (currentMember?.attendeeRole != nil) {
                role = MemberRoles.Attendee
            }
        }
        return role
    }
}
