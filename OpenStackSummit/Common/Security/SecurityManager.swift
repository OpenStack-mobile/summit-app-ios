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
    var member: Member!
    
    private let kCurrentMemberId = "currentMemberId"
    private let kCurrentMemberFullName = "currentMemberFullName"
    private let kDeviceHadPasscode = "deviceHadPasscode"
    private let kLoggedInNotConfirmedAttendee = -1
    
    
    public override init() {
        super.init()
        NSNotificationCenter.defaultCenter().removeObserver(self, name: OAuth2Module.revokeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "revokedAccess:",
            name: OAuth2Module.revokeNotification,
            object: nil)
    }
    
    private var deviceHadPasscode: Bool? {
        get {
            return session.get(kDeviceHadPasscode) as? Bool
        }
        set {
            session.set(kDeviceHadPasscode, value: newValue)
        }
    }
    
    private func checkState() {
        if let currentMemberId = session.get(kCurrentMemberId) as? Int {
            if (currentMemberId == kLoggedInNotConfirmedAttendee && member == nil) {
                member = Member()
                member.id = currentMemberId
                if let fullName = session.get(kCurrentMemberFullName) as? String {
                    member.fullName = fullName;
                }
            }
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
            scopes: ["openid",
                "profile",
                "offline_access",
                "\(Constants.Urls.ResourceServerBaseUrl)/summits/read",
                "\(Constants.Urls.ResourceServerBaseUrl)/summits/write",
                "\(Constants.Urls.ResourceServerBaseUrl)/summits/read-external-orders",
                "\(Constants.Urls.ResourceServerBaseUrl)/summits/confirm-external-orders"
            ],
            clientSecret: Constants.Auth.SecretOpenID,
            isWebView: true
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
        
        session = hasPasscode ? TrustedPersistantOAuth2Session(accountId: config.accountId!) : UntrustedMemoryOAuth2Session.getInstance(config.accountId!)

        return AccountManager.addAccount(config, session: session, moduleClass: OpenStackOAuth2Module.self)
    }
    
    public func login(completionBlock: (NSError?) -> Void, partialCompletionBlock: (Void) -> Void) {
        oauthModuleOpenID.login {(accessToken: AnyObject?, claims: OpenIDClaim?, error: NSError?) in // [1]
            if error != nil {
                printerr(error)
                return
            }
            
            partialCompletionBlock()
            
            if accessToken == nil {
                return
            }
            
            
            self.linkAttendeeIfExist(completionBlock);
        }
    }
    
    public func linkAttendeeIfExist(completionBlock: (NSError?) -> Void) {
        self.memberDataStore.getLoggedInMemberOrigin() { (member, error) in
            
            if error != nil {
                if error?.code == 404 {
                    
                    self.getLoggedInMemberBasicInfoOrigin(completionBlock)
                }
                else {
                    completionBlock(error)
                }
            }
            else {
                self.session.set(self.kCurrentMemberId, value: member!.id)
                self.session.set(self.kCurrentMemberFullName, value: member!.fullName)
                
                completionBlock(error)
                
                let notification = NSNotification(name: Constants.Notifications.LoggedInNotification, object:nil, userInfo:nil)
                NSNotificationCenter.defaultCenter().postNotification(notification)
            }
        }
    }
    
    private func getLoggedInMemberBasicInfoOrigin(completionBlock: (NSError?) -> Void) {
        self.memberDataStore.getLoggedInMemberBasicInfoOrigin() { (member, error) in
            if error != nil {
                completionBlock(error)
                return
            }
            
            self.member = member
            if member != nil && member!.id > 0 {
                self.session.set(self.kCurrentMemberId, value: member!.id)
            }
            else {
                self.session.set(self.kCurrentMemberId, value: self.kLoggedInNotConfirmedAttendee)
            }
            
            self.session.set(self.kCurrentMemberFullName, value: member!.fullName)
            
            completionBlock(error)
            
            let notification = NSNotification(name: Constants.Notifications.LoggedInNotification, object:nil, userInfo:nil)
            NSNotificationCenter.defaultCenter().postNotification(notification)
        }
    }
    
    public func logout(completionBlock: ((NSError?) -> Void)?) {
        oauthModuleOpenID.revokeLocalAccess(false)
        self.session.set(self.kCurrentMemberId, value: nil)
        self.session.set(self.kCurrentMemberFullName, value: nil)
        
        member = nil
        
        let notification = NSNotification(name: Constants.Notifications.LoggedOutNotification, object:nil, userInfo:nil)
        NSNotificationCenter.defaultCenter().postNotification(notification)
        
        // TODO: logout is no longer async, delete completition block
        if completionBlock != nil {
            completionBlock!(nil)
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
            else {
                role = MemberRoles.Member
            }
        }
        return role
    }
    
    public func getCurrentMember() -> Member? {
        if isLoggedIn() {
            let currentMemberId = session.get(kCurrentMemberId) as! Int
            if currentMemberId > 0 {
                let currentMember = memberDataStore.getByIdLocal(currentMemberId)
                member = currentMember
            }
        }
        return member;
    }
    
    public func isLoggedIn() -> Bool {
        checkState()
        return session.get(kCurrentMemberId) != nil
    }
    
    public func isLoggedInAndConfirmedAttendee() -> Bool {
        let currentMemberId = session.get(kCurrentMemberId) as? Int
        return isLoggedIn() && currentMemberId != kLoggedInNotConfirmedAttendee;
    }
    
    
    func revokedAccess(notification: NSNotification) {
        self.session.set(self.kCurrentMemberId, value: nil)
        let notification = NSNotification(name: Constants.Notifications.LoggedOutNotification, object:nil, userInfo:nil)
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
}
