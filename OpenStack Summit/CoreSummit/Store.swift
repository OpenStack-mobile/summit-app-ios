//
//  Store.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/14/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation
import RealmSwift

/// Class used for requesting and caching data from the server.
public final class Store {
    
    // MARK: - Singleton
    
    /// Singleton Store instance
    public static let shared = Store()
    
    // MARK: - Properties
    
    /// The Realm storage context.
    public let realm = try! Realm()
    
    /// Request queue
    private let requestQueue: NSOperationQueue = {
        
        let queue = NSOperationQueue()
        
        queue.name = "\(Store.self) Request Queue"
        
        return queue
    }()
    
    // MARK: - Internal / Private Methods
    
    /// Convenience function for adding a block to the request queue.
    internal func newRequest(block: () -> ()) {
        
        self.requestQueue.addOperationWithBlock(block)
    }
    
    /*
    private func configOAuthAccounts() {
        
        let hasPasscode = deviceHasPasscode
        
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
    }
    
    private func createOAuthModule(config: Config, hasPasscode: Bool) -> OAuth2Module {
        var session: OAuth2Session
        
        config.accountId = "ACCOUNT_FOR_CLIENTID_\(config.clientId)"
        
        session = TrustedPersistantOAuth2Session(accountId: config.accountId!)
        session.clearTokens()
        
        session = hasPasscode ? TrustedPersistantOAuth2Session(accountId: config.accountId!) : UntrustedMemoryOAuth2Session.init(accountId: config.accountId!)
        
        return AccountManager.addAccount(config, session: session, moduleClass: OpenStackOAuth2Module.self)
    }
    */
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
