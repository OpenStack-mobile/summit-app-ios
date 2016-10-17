//
//  Store.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/14/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation
import AeroGearHttp
import AeroGearOAuth2
import RealmSwift

/// Class used for requesting and caching data from the server.
public final class Store {
    
    // MARK: - Singleton
    
    /// Singleton Store instance
    public static let shared = Store()
    
    // MARK: - Properties
    
    /// The Realm storage context.
    public let realm = try! Realm()
    
    public var environment = Environment.Staging {
        
        didSet { configOAuthAccounts() }
    }
    
    public var session: SessionStorage? {
        
        didSet { session?.hadPasscode = deviceHasPasscode }
    }
    
    // MARK: - Private / Internal Properties
    
    /// Request queue
    private let requestQueue: NSOperationQueue = {
        
        let queue = NSOperationQueue()
        
        queue.name = "\(Store.self) Request Queue"
        
        return queue
    }()
    
    internal var oauthModuleOpenID: OAuth2Module!
    
    internal var oauthModuleServiceAccount: OAuth2Module!
    
    // MARK: - Initialization
    
    deinit {
        
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    private init() {
        
        configOAuthAccounts()
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: OAuth2Module.revokeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: #selector(revokedAccess),
            name: OAuth2Module.revokeNotification,
            object: nil)
    }
    
    // MARK: - Accessors
    
    public var deviceHasPasscode: Bool {
        
        let secret = "Device has passcode set?".dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)
        let attributes = [kSecClass as String: kSecClassGenericPassword, kSecAttrService as String: "LocalDeviceServices", kSecAttrAccount as String:"NoAccount", kSecValueData as String: secret!, kSecAttrAccessible as String:kSecAttrAccessibleWhenPasscodeSetThisDeviceOnly]
        
        let status = SecItemAdd(attributes, nil)
        if status == 0 {
            SecItemDelete(attributes)
            return true
        }
        return false
    }
    
    // MARK: - Internal / Private Methods
    
    /// Convenience function for adding a block to the request queue.
    internal func newRequest(block: () -> ()) {
        
        self.requestQueue.addOperationWithBlock(block)
    }
    
    // MARK: - OAuth2
    
    internal func createHTTP(type: RequestType) -> Http {
        
        let http: Http
        if (type == .OpenIDGetFormUrlEncoded) {
            http = Http(responseSerializer: StringResponseSerializer())
            http.authzModule = oauthModuleOpenID
        }
        else if (type == .OpenIDJSON) {
            http = Http(responseSerializer: StringResponseSerializer(), requestSerializer: JsonRequestSerializer())
            http.authzModule = oauthModuleOpenID
        }
        else {
            http = Http(responseSerializer: StringResponseSerializer())
            http.authzModule = oauthModuleServiceAccount
        }
        return http
    }
    
    private func configOAuthAccounts() {
        
        let hasPasscode = deviceHasPasscode
        
        var config = Config(
            base: environment.configuration.authenticationURL,
            authzEndpoint: "oauth2/auth",
            redirectURL: "org.openstack.ios.openstack-summit://oauthCallback",
            accessTokenEndpoint: "oauth2/token",
            clientId: environment.configuration.openID.client,
            refreshTokenEndpoint: "oauth2/token",
            revokeTokenEndpoint: "oauth2/token/revoke",
            isOpenIDConnect: true,
            userInfoEndpoint: "api/v1/users/info",
            scopes: ["openid",
                "profile",
                "offline_access",
                "\(environment.configuration.serverURL)/summits/read",
                "\(environment.configuration.serverURL)/summits/write",
                "\(environment.configuration.serverURL)/summits/read-external-orders",
                "\(environment.configuration.serverURL)/summits/confirm-external-orders"
            ],
            clientSecret: environment.configuration.openID.secret,
            isWebView: true
        )
        oauthModuleOpenID = createOAuthModule(config, hasPasscode: hasPasscode)
        
        config = Config(
            base: environment.configuration.authenticationURL,
            authzEndpoint: "oauth2/auth",
            redirectURL: "org.openstack.ios.openstack-summit://oauthCallback",
            accessTokenEndpoint: "oauth2/token",
            clientId: environment.configuration.serviceAccount.client,
            revokeTokenEndpoint: "oauth2/token/revoke",
            isServiceAccount: true,
            userInfoEndpoint: "api/v1/users/info",
            scopes: ["\(environment.configuration.serverURL)/summits/read"],
            clientSecret: environment.configuration.serviceAccount.secret
        )
        oauthModuleServiceAccount = createOAuthModule(config, hasPasscode: hasPasscode)
    }
    
    private func createOAuthModule(config: AeroGearOAuth2.Config, hasPasscode: Bool) -> OAuth2Module {
        var session: OAuth2Session
        
        config.accountId = "ACCOUNT_FOR_CLIENTID_\(config.clientId)"
        
        if let hadPasscode = self.session?.hadPasscode {
            if hadPasscode && !hasPasscode {
                session = TrustedPersistantOAuth2Session(accountId: config.accountId!)
                session.clearTokens()
            }
        }
        
        session = hasPasscode ? TrustedPersistantOAuth2Session(accountId: config.accountId!) : UntrustedMemoryOAuth2Session.getInstance(config.accountId!)
        
        return AccountManager.addAccount(config, session: session, moduleClass: OpenStackOAuth2Module.self)
    }
    
    @objc private func revokedAccess(notification: NSNotification) {
        
        self.session?.clear()
        
        let notification = NSNotification(name: Notification.ForcedLoggedOut.rawValue, object:self, userInfo:nil)
        NSNotificationCenter.defaultCenter().postNotification(notification)
    }
}

// MARK: - Supporting Types

/// Convenience function for adding a block to the main queue.
internal func mainQueue(block: () -> ()) {
    
    NSOperationQueue.mainQueue().addOperationWithBlock(block)
}

public extension Store {
    
    public enum Error: ErrorType {
        
        /// The server returned a status code indicating an error.
        case ErrorStatusCode(Int)
        
        /// The server returned an invalid response.
        case InvalidResponse
        
        /// A custom error from the server.
        case CustomServerError(String)
    }
}

public extension Store {
    
    public enum Notification: String {
        
        case LoggedIn           = "CoreSummit.Store.Notification.LoggedIn"
        case LoggedOut          = "CoreSummit.Store.Notification.LoggedOut"
        case ForcedLoggedOut    = "CoreSummit.Store.Notification.ForcedLoggedOut"
    }
}

internal extension Store {
    
    enum RequestType {
        
        case OpenIDGetFormUrlEncoded, OpenIDJSON, ServiceAccount
    }
}
