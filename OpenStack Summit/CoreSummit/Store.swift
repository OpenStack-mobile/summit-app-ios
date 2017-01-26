//
//  Store.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 6/14/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData
import SwiftFoundation
import AeroGearHttp
import AeroGearOAuth2

/// Class used for requesting and caching data from the server.
public final class Store {
    
    // MARK: - Properties
    
    /// The managed object context used for caching.
    public let managedObjectContext: NSManagedObjectContext
    
    /// A convenience variable for the managed object model.
    public let managedObjectModel: NSManagedObjectModel
    
    /// Block for creating the persistent store.
    public let createPersistentStore: (NSPersistentStoreCoordinator) throws -> NSPersistentStore
    
    /// Block for resetting the persistent store.
    public let deletePersistentStore: (NSPersistentStoreCoordinator, NSPersistentStore) throws -> ()
    
    /// The server targeted environment. 
    public let environment: Environment
    
    /// Provides the storage for session values. 
    public var session: SessionStorage
    
    // MARK: - Private / Internal Properties
    
    private let persistentStoreCoordinator: NSPersistentStoreCoordinator
    
    private var persistentStore: NSPersistentStore
    
    /// The managed object context running on a background thread for asyncronous caching.
    public let privateQueueManagedObjectContext = NSManagedObjectContext(concurrencyType: NSManagedObjectContextConcurrencyType.PrivateQueueConcurrencyType)
    
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
    
        // stop recieving 'didSave' notifications from private context
        NSNotificationCenter.defaultCenter().removeObserver(self, name: NSManagedObjectContextDidSaveNotification, object: self.privateQueueManagedObjectContext)
    
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    public init(environment: Environment,
                 session: SessionStorage,
                 contextConcurrencyType: NSManagedObjectContextConcurrencyType = .MainQueueConcurrencyType,
                 createPersistentStore: (NSPersistentStoreCoordinator) throws -> NSPersistentStore,
                 deletePersistentStore: (NSPersistentStoreCoordinator, NSPersistentStore) throws -> ()) throws {
        
        // store values
        self.environment = environment
        self.session = session
        self.createPersistentStore = createPersistentStore
        self.deletePersistentStore = deletePersistentStore
        
        // set managed object model
        self.managedObjectModel = NSManagedObjectModel.summitModel
        self.persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        
        // setup managed object contexts
        self.managedObjectContext = NSManagedObjectContext(concurrencyType: contextConcurrencyType)
        self.managedObjectContext.undoManager = nil
        self.managedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        
        self.privateQueueManagedObjectContext.undoManager = nil
        self.privateQueueManagedObjectContext.persistentStoreCoordinator = persistentStoreCoordinator
        self.privateQueueManagedObjectContext.name = "\(Store.self) Private Managed Object Context"
        
        // configure CoreData backing store
        self.persistentStore = try createPersistentStore(persistentStoreCoordinator)
        
        // listen for notifications (for merging changes)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(Store.mergeChangesFromContextDidSaveNotification(_:)), name: NSManagedObjectContextDidSaveNotification, object: self.privateQueueManagedObjectContext)
        
        
        // config OAuth and HTTP
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
    
    // MARK: - Methods
    
    public func clear() throws {
        
        try self.deletePersistentStore(persistentStoreCoordinator, persistentStore)
        self.persistentStore = try self.createPersistentStore(persistentStoreCoordinator)
        
        self.managedObjectContext.reset()
        self.privateQueueManagedObjectContext.reset()
        
        // manually send notification
        NSNotificationCenter.defaultCenter().postNotificationName(NSManagedObjectContextObjectsDidChangeNotification, object: self.managedObjectContext, userInfo: [:])
    }
    
    // MARK: - Internal / Private Methods
    
    /// Convenience function for adding a block to the request queue.
    @inline(__always)
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
                "\(environment.configuration.serverURL)/me/read",
                "\(environment.configuration.serverURL)/summits/read",
                "\(environment.configuration.serverURL)/summits/write",
                "\(environment.configuration.serverURL)/summits/read-external-orders",
                "\(environment.configuration.serverURL)/summits/confirm-external-orders",
                "\(environment.configuration.serverURL)/teams/read",
                "\(environment.configuration.serverURL)/teams/write",
                "\(environment.configuration.serverURL)/members/invitations/read",
                "\(environment.configuration.serverURL)/members/invitations/write"
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
            scopes: ["\(environment.configuration.serverURL)/summits/read",
                "\(environment.configuration.serverURL)/members/read"
            ],
            clientSecret: environment.configuration.serviceAccount.secret
        )
        oauthModuleServiceAccount = createOAuthModule(config, hasPasscode: hasPasscode)
    }
    
    private func createOAuthModule(config: AeroGearOAuth2.Config, hasPasscode: Bool) -> OAuth2Module {
        var session: OAuth2Session
        
        config.accountId = "ACCOUNT_FOR_CLIENTID_\(config.clientId)"
        
        if self.session.hadPasscode && !hasPasscode {
            
            session = TrustedPersistantOAuth2Session(accountId: config.accountId!)
            session.clearTokens()
        }
        
        session = hasPasscode ? TrustedPersistantOAuth2Session(accountId: config.accountId!) : UntrustedMemoryOAuth2Session.getInstance(config.accountId!)
        
        return AccountManager.addAccount(config, session: session, moduleClass: OpenStackOAuth2Module.self)
    }
    
    // MARK: Notifications
    
    @objc private func mergeChangesFromContextDidSaveNotification(notification: NSNotification) {
        
        self.managedObjectContext.performBlockAndWait {
            
            self.managedObjectContext.mergeChangesFromContextDidSaveNotification(notification)
            
            // manually send notification
            NSNotificationCenter.defaultCenter().postNotificationName(NSManagedObjectContextObjectsDidChangeNotification, object: self.managedObjectContext, userInfo: notification.userInfo)
        }
    }
    
    @objc private func revokedAccess(notification: NSNotification) {
        
        self.session.clear()
        
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
