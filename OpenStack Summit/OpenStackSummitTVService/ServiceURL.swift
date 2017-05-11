//
//  ServiceURL.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/11/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import CoreSummit

struct ServiceURL {
    
    static let scheme = "openstacktvservice"
    
    var identifier: Identifier
    
    init(identifier: Identifier) {
        
        self.identifier = identifier
    }
    
    init?(url: NSURL) {
        
        guard let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false),
            let identifierString = components.queryItems?.first(where: { $0.name == QueryItem.identifier.rawValue })?.value,
            let identifier = Int(identifierString)
            else { return nil }
        
        self.identifier = identifier
    }
    
    var url: NSURL {
        
        let components = NSURLComponents()
        
        components.scheme = type(of: self).scheme
        
        components.queryItems = [NSURLQueryItem(name: QueryItem.identifier.rawValue, value: "\(identifier)")]
        
        return components.URL!
    }
}

// MARK: - Supporting Types

extension ServiceURL {
    
    enum QueryItem: String {
        
        case identifier
    }
}
