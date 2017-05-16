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
    
    init?(url: URL) {
        
        guard let components = URLComponents(url: url as URL, resolvingAgainstBaseURL: false),
            let identifierString = components.queryItems?.first(where: { $0.name == QueryItem.identifier.rawValue })?.value,
            let identifier = Identifier(identifierString)
            else { return nil }
        
        self.identifier = identifier
    }
    
    var url: URL {
        
        var components = URLComponents()
        
        components.scheme = type(of: self).scheme
        
        components.queryItems = [URLQueryItem(name: QueryItem.identifier.rawValue, value: "\(identifier)") as URLQueryItem]
        
        return components.url!
    }
}

// MARK: - Supporting Types

extension ServiceURL {
    
    enum QueryItem: String {
        
        case identifier
    }
}
