//
//  URLConvertible.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 8/31/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import SwiftFoundation

/// A type which can export a URL to open the summit data on the website.
public protocol WebConvertible: Unique {
    
    static var webPathComponent: String { get }
}

public extension WebConvertible {
    
    func toURL(configuration: Configuration, summit: Summit) -> String {
        
        return configuration[.WebsiteURL] + "/summit/" + summit.webIdentifier + "/summit-schedule/" + Self.webPathComponent + "/\(identifier)"
    }
}

// MARK: - Model Extensions

public extension Summit {
    
    var webIdentifier: String {
        
        let year = DateComponents(fromDate: start).year
        
        return name.lowercaseString + "-" + "\(year)"
    }
}

extension Event: WebConvertible {
    
    public static let webPathComponent = "events"
}

extension PresentationSpeaker: WebConvertible {
    
    public static let webPathComponent = "speakers"
}