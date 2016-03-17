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
    
    var internalOAuthModuleOpenID: OAuth2Module!
    var internalOAuthModuleServiceAccount: OAuth2Module!
    
    var memberDataStore: IMemberDataStore!
    
    private let kCurrentMemberId = "currentMemberId"
    private let kDeviceHadPasscode = "deviceHadPasscode"
    
    private var deviceHadPasscode: Bool? {
        get {
            return session.get(kDeviceHadPasscode) as? Bool
        }
        set {
            session.set(kDeviceHadPasscode, value: newValue)
        }
    }
    
    public func deviceHasPasscode() -> Bool {
        let secret = "Device has passcode set?".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        let attributes = [kSecClass as String:kSecClassGenericPassword, kSecAttrService as String:"LocalDeviceServices", kSecAttrAccount as String:"NoAccount", kSecValueData as String:secret!, kSecAttrAccessible as String:kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly]
        
        let status = SecItemAdd(attributes, nil)
        if status == 0 {
            SecItemDelete(attributes)
            return true
        }
        return false
    }
    
    public func checkPasscodeSettingChange() {
        if let hadPasscode = deviceHadPasscode {
            if hadPasscode != deviceHasPasscode() {
                configOAuthAccounts()
            }
        }
    }
    
    public var oauthModuleOpenID: OAuth2Module! {
        get {
            if internalOAuthModuleOpenID == nil {
                configOAuthAccounts()
            }
            return internalOAuthModuleOpenID
        }
        set {
            internalOAuthModuleOpenID = newValue
        }
    }
    
    public var oauthModuleServiceAccount: OAuth2Module! {
        get {
            if internalOAuthModuleServiceAccount == nil {
                configOAuthAccounts()
            }
            return internalOAuthModuleServiceAccount
        }
        set {
            internalOAuthModuleServiceAccount = newValue
        }
    }
    
    public func configOAuthAccounts() {
        let hasPasscode = deviceHasPasscode()
        
        var config = Config(
            base: Constants.Urls.AuthServerBaseUrl,
            authzEndpoint: "oauth2/auth",
            redirectURL: "org.openstack.ios.openstack-summit://oauthCallback",
            accessTokenEndpoint: "oauth2/token",
            clientId: Constants.Auth.ClientIdOpenID,
            refreshTokenEndpoint: "oauth2/token",
            revokeTokenEndpoint: "oauth2/token/revoke",
            isOpenIDConnect: true,
            userInfoEndpoint: "api/v1/users/info",
            scopes: ["openid", "\(Constants.Urls.ResourceServerBaseUrl)/summits/read", "\(Constants.Urls.ResourceServerBaseUrl)/summits/write", "offline_access"],
            clientSecret: Constants.Auth.SecretOpenID
        )
        oauthModuleOpenID = createOAuthModule(config, hasPasscode: hasPasscode)
        
        config = Config(
            base: Constants.Urls.AuthServerBaseUrl,
            authzEndpoint: "oauth2/auth",
            redirectURL: "org.openstack.ios.openstack-summit://oauthCallback",
            accessTokenEndpoint: "oauth2/token",
            clientId: Constants.Auth.ClientIdServiceAccount,
            revokeTokenEndpoint: "oauth2/token/revoke",
            isServiceAccount: true,
            userInfoEndpoint: "api/v1/users/info",
            scopes: ["\(Constants.Urls.ResourceServerBaseUrl)/summits/read"],
            clientSecret: Constants.Auth.SecretServiceAccount
        )
        oauthModuleServiceAccount = createOAuthModule(config, hasPasscode: hasPasscode)
        
        deviceHadPasscode = hasPasscode
    }
    
    public func createOAuthModule(config: Config, hasPasscode: Bool) -> OAuth2Module {
        var session: OAuth2Session
        
        config.accountId = "ACCOUNT_FOR_CLIENTID_\(config.clientId)"
        
        if let hadPasscode = deviceHadPasscode {
            if hadPasscode && !hasPasscode {
                session = TrustedPersistantOAuth2Session(accountId: config.accountId!)
                session.clearTokens()
            }
        }
        
        session = hasPasscode ? TrustedPersistantOAuth2Session(accountId: config.accountId!) : UntrustedMemoryOAuth2Session(accountId: config.accountId!)

        return AccountManager.addAccount(config, session: session, moduleClass: OpenStackOAuth2Module.self)
    }
    
    public func login(completionBlock: (NSError?) -> Void) {
        oauthModuleOpenID.login {(accessToken: AnyObject?, claims: OpenIDClaim?, error: NSError?) in // [1]
            if error != nil {
                print(error)
                return
            }
            
            if accessToken == nil {
                return
            }
            
            self.memberDataStore.getLoggedInMemberOrigin() { (member, error) in
                
                if error != nil {
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
        if isLoggedIn() {
            currentMember = memberDataStore.getByIdLocal(session.get(kCurrentMemberId) as! Int)
        }
        return currentMember;
    }
    
    public func isLoggedIn() -> Bool {
        return session.get(kCurrentMemberId) != nil
    }
    
}
