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
            base: "https://testopenstackid.openstack.org",
            authzEndpoint: "oauth2/auth",
            redirectURL: "org.openstack.ios.openstack-summit://oauthCallback",
            accessTokenEndpoint: "oauth2/token",
            clientId: "ugSc.5IJB7MOpVHOs4anxyZi~PJsIfJJ.openstack.client",
            revokeTokenEndpoint: "oauth2/token/revoke",
            isOpenIDConnect: true,
            userInfoEndpoint: "api/v1/users/info",
            scopes: ["openid", "https://testresource-server.openstack.org/summits/read"],
            clientSecret: "NvEAT3ScN5c5p9yPS67GeoBo2M_8YLFezeAdALF~dsD-pxXmBU6JRL0ZOyNpGEhM"
        )
        
        oauthModuleOpenID = AccountManager.addAccount(config, moduleClass: OpenStackOAuth2Module.self)

        config = Config(
            base: "https://testopenstackid.openstack.org",
            authzEndpoint: "oauth2/auth",
            redirectURL: "org.openstack.ios.openstack-summit://oauthCallback",
            accessTokenEndpoint: "oauth2/token",
            clientId: "m22i15-mlfb9pa7_xE9awfGchL0emthA.openstack.client",
            revokeTokenEndpoint: "oauth2/token/revoke",
            isServiceAccount: true,
            userInfoEndpoint: "api/v1/users/info",
            scopes: ["https://testresource-server.openstack.org/summits/read"],
            clientSecret: "NWqDnFMdQrR.KNUfjPu-4SZUrABnHsM1SbwSsvOV4uk0jGI7X7DPC~WCsMSVH4Ci"
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
