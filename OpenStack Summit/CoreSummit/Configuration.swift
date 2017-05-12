//
//  Config.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 7/28/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

/// OpenStack Summit constants.
public protocol Configuration {
    
    /// URL of the REST server
    static var serverURL: String { get }
    
    /// URL of the OpenStack ID server.
    static var authenticationURL: String { get }
    
    static var openID: (client: String, secret: String) { get }
    
    static var serviceAccount: (client: String, secret: String) { get }
    
    /// OpenStack Summit Webpage URL.
    static var webpage: URL { get }
}

public extension Environment {
    
    var configuration: Configuration.Type {
        
        switch self {
        case .staging: return Staging.self
        case .production: return Production.self
        }
    }
}
