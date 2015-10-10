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
    var memberDataStore: IMemberDataStore!
    private let kCurrentMemberId = "currentMemberId"
    
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
            
            self.memberDataStore.getLoggedInMemberOrigin() { (member, error) in
                
                if (error != nil) {
                    completionBlock(error)
                    return
                }
                
                self.session.set(self.kCurrentMemberId, value: member!.id)
                completionBlock(error)
                
                let notification = NSNotification(name: Constants.Notifications.LoggedInNotification, object:nil, userInfo:nil)
                NSNotificationCenter.defaultCenter().postNotification(notification)
            }
        }
    }
    
    public func logout(completionBlock: (NSError?) -> Void) {
        oauthModuleOpenID.revokeAccess() { (response, error) in
            self.session.set(self.kCurrentMemberId, value: nil)
            completionBlock(error)

            let notification = NSNotification(name: Constants.Notifications.LoggedOutNotification, object:nil, userInfo:nil)
            NSNotificationCenter.defaultCenter().postNotification(notification)
        }
    }
    
    public func getCurrentMemberRole() -> MemberRoles{
        
        var role = MemberRoles.Anonymous
        let currentMember = getCurrentMember()
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
    
    public func getCurrentMember() -> Member? {
        var currentMember: Member?
        if (oauthModuleOpenID.isAuthorized() && session.get(kCurrentMemberId) != nil) {
            currentMember = memberDataStore.getByIdLocal(session.get(kCurrentMemberId) as! Int)
        }
        return currentMember;
    }
    
    public func isLoggedIn() -> Bool {
        return oauthModuleOpenID.isAuthorized() && session.get(kCurrentMemberId) != nil
    }
}
