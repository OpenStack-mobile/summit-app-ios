//
//  Store.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/14/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation
import RealmSwift
import AeroGearHttp
import AeroGearOAuth2

/// Class used for requesting and caching data from the server.
public final class Store {
    
    // MARK: - Singleton
    
    /// Singleton Store instance
    public static let shared = Store()
    
    // MARK: - Properties
    
    public let realm = try! Realm()
    
    // The HTTP client that will be used to execute the requests to the server.
    public var client: HTTP.Client { return HTTP.Client() }
    
    /// The URL of the server.
    public var serverURL: String = "https://dev-resource-server"
    
    /// Request queue
    private let requestQueue: NSOperationQueue = {
        
        let queue = NSOperationQueue()
        
        queue.name = "\(Store.self) Request Queue"
        
        return queue
    }()
    
    public private(set) var oauthModuleOpenID: OAuth2Module?
    
    public private(set) var oauthModuleServiceAccount: OAuth2Module?
    
    // MARK: - Initialization
    
    private init() {
        
        configOAuthAccounts()
        
        
        NSNotificationCenter.defaultCenter().removeObserver(self, name: OAuth2Module.revokeNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "revokedAccess:",
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
    
    internal func addHeaders(inout request: HTTP.Request) {
        
        request.headers["Content-Type"] = "application/json"
    }
    
    // MARK: Requests
    
    internal func getEntity<T where T: JSONDecodable, T: RealmEncodable>(request: HTTP.Request, completion: ErrorValue<T> -> ()) {
        
        /// **Get Entity** parsing method
        func parse(response: HTTP.Response) throws -> T  {
            
            guard response.statusCode == HTTP.StatusCode.OK.rawValue
                else { throw Error.ErrorStatusCode(response.statusCode) }
            
            guard let jsonString = String(UTF8Data: response.body),
                let json = JSON.Value(string: jsonString),
                let entity = T(JSONValue: json)
                else { throw Error.InvalidResponse }
            
            return entity
        }
        
        // execute request
        newRequest {
            
            let entity: T
            
            do {
                let response = try self.client.sendRequest(request)
                
                entity = try parse(response)
                
                // cache in Realm
                try! self.realm.write { let _ = entity.save(self.realm) }
            }
                
            catch { mainQueue { completion(.Error(error)) }; return }
            
            mainQueue { completion(.Value(entity)) }
        }
    }
    
    // MARK: - OAuth2
    
    private func create(type: HttpRequestType) -> Http {
        
        // create the oauth accounts
        configOAuthAccounts()
        
        let http: Http
        if (type == .OpenIDGetFormUrlEncoded) {
            http = Http(responseSerializer: StringResponseSerializer())
            http.authzModule = oauthModuleOpenID
        }
        else if (type == .OpenIDJson) {
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
    
    public func login(completionBlock: (NSError?) -> Void, partialCompletionBlock: (Void) -> Void) {
        
        oauthModuleOpenID!.login {(accessToken: AnyObject?, claims: OpenIDClaim?, error: NSError?) in // [1]
            
            /*
            if error != nil {
                printerr(error)
                Crashlytics.sharedInstance().recordError(error!)
                return
            }
            
            partialCompletionBlock()
            
            if accessToken == nil {
                return
            }
            
            
            self.linkAttendeeIfExist(completionBlock);
            */
        }
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

public enum HttpRequestType {
    
    case OpenIDGetFormUrlEncoded, OpenIDJson, ServiceAccount
}
