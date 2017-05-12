//
//  URLConvertible.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 8/31/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation

/// A type which can export a URL to open the summit data on the website.
public protocol WebConvertible: Unique {
    
    static var webPathComponent: WebPathComponent { get }
}

public extension WebConvertible {
    
    func toWebpage(_ summit: Summit) -> URL {
        
        return URL(string: summit.webpage.absoluteString + "/summit-schedule/" + Self.webPathComponent.rawValue + "/\(identifier)")!
    }
}

public enum WebPathComponent: String {
    
    case events
    case speakers
}

// MARK: - Model Extensions

extension Event: WebConvertible {
    
    public static let webPathComponent = WebPathComponent.events
}

extension Speaker: WebConvertible {
    
    public static let webPathComponent = WebPathComponent.speakers
}
