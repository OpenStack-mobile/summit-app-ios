//
//  URLExtensions.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 5/13/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import struct Foundation.URL

extension URL {
    
    /// Fixes the scheme (e.g. https/http) according to environment.
    var environmentScheme: URL {
        
        switch AppEnvironment {
            
        case .staging:
            
            var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: false)!
            
            urlComponents.scheme = "http"
            
            return urlComponents.url!
            
        case .production:
            
            return self
        }
    }
}
