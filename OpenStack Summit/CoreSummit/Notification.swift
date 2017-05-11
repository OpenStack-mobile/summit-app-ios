//
//  Notification.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 1/27/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import struct Foundation.Date

public struct Notification: Unique {
    
    public let identifier: Identifier
    
    public let body: String
    
    public let created: Date
    
    public let from: Topic
    
    public let summit: Identifier
    
    public let channel: Channel
    
    public let event: Identifier?
}

// MARK: - Equatable

public func == (lhs: Notification, rhs: Notification) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.body == rhs.body
        && lhs.created == rhs.created
        && lhs.from == rhs.from
        && lhs.summit == rhs.summit
        && lhs.channel == rhs.channel
        && lhs.event == rhs.event
}

public func == (lhs: Notification.Topic, rhs: Notification.Topic) -> Bool {
    
    switch (lhs, rhs) {
        
    case (.attendees, .attendees): return true
    case (.speakers, .speakers): return true
    case (.everyone, .everyone): return true
    case let (.summit(lhsValue), .summit(rhsValue)): return lhsValue == rhsValue
    case let (.team(lhsValue), .team(rhsValue)): return lhsValue == rhsValue
    case let (.member(lhsValue), .member(rhsValue)): return lhsValue == rhsValue
    case let (.event(lhsValue), .event(rhsValue)): return lhsValue == rhsValue
    default: return false
    }
}

// MARK: - Supporting Types

public extension Notification {
    
    public enum Channel: String {
        
        case everyone = "EVERYONE"
        case speakers = "SPEAKERS"
        case attendees = "ATTENDEES"
        case members = "MEMBERS"
        case summit = "SUMMIT"
        case event = "EVENT"
        case group = "GROUP"
    }
    
    public enum Topic: RawRepresentable, Equatable, Hashable {
        
        case summit(Identifier)
        case team(Identifier)
        case member(Identifier)
        case event(Identifier)
        case attendees
        case speakers
        case everyone
        
        public var identifier: Identifier? {
            
            switch self {
            case let .summit(identifier): return identifier
            case let .team(identifier): return identifier
            case let .member(identifier): return identifier
            case let .event(identifier): return identifier
            default: return nil
            }
        }
        
        private enum Prefix: String {
            
            case summit, member, event, team, attendees, speakers, everyone
            
            init(_ topic: Topic) {
                
                switch topic {
                    
                case .summit:       self = .summit
                case .team:         self = .team
                case .member:       self = .member
                case .event:        self = .event
                case .attendees:    self = .attendees
                case .speakers:     self = .speakers
                case .everyone:     self = .everyone
                }
            }
        }
        
        private static func parse(_ string: String, with prefix: String) -> Notification.Topic? {
            
            let rawValue = string
            
            let topicPrefixString = prefix
            
            struct Cache {
                static var prefixRegularExpressions = [String: [Prefix: NSRegularExpression]]()
            }
            
            func parseIdentifier(_ prefix: Prefix) -> Identifier? {
                
                let prefixString = topicPrefixString + prefix.rawValue + "_"
                
                guard rawValue.contains(prefixString) else { return nil }
                
                // get regex
                
                let regularExpression: NSRegularExpression
                
                let regularExpressionsForPrefix: [Prefix: NSRegularExpression]
                
                if let cached = Cache.prefixRegularExpressions[topicPrefixString] {
                    
                    regularExpressionsForPrefix = cached
                    
                } else {
                    
                    regularExpressionsForPrefix = [Prefix: NSRegularExpression]()
                    
                    // create new cache for prefix
                    Cache.prefixRegularExpressions[topicPrefixString] = regularExpressionsForPrefix
                }
                
                if let cached = regularExpressionsForPrefix[prefix] {
                    
                    regularExpression = cached
                    
                } else {
                    
                    regularExpression = try! NSRegularExpression(pattern: prefixString + "(\\d+)", options: [])
                    
                    // add to cache
                    Cache.prefixRegularExpressions[topicPrefixString]![prefix] = regularExpression
                }
                
                // run regex
                
                guard let match = regularExpression.firstMatch(in: rawValue, options: [], range: NSMakeRange(0, (rawValue as NSString).length)), match.numberOfRanges == 2
                    else { return nil }
                
                let matchString = (rawValue as NSString).substring(with: match.range)
                
                guard matchString == rawValue
                    else { return nil }
                
                let captureGroup = (rawValue as NSString).substring(with: match.rangeAt(1))
                
                guard let identifier = Identifier(captureGroup)
                    else { return nil }
                
                return identifier
            }
            
            func parseCollection() -> Topic? {
                
                let prefixString = rawValue.replacingOccurrences(of: topicPrefixString, with: "")
                
                guard let prefix = Prefix(rawValue: prefixString)
                    else { return nil }
                
                switch prefix {
                case .attendees: return .attendees
                case .everyone: return .everyone
                case .speakers: return .speakers
                default: return nil
                }
            }
            
            // main `if-else` parsing statement
            
            if let collectionTopic = parseCollection() {
                
                return collectionTopic
                
            } else if let identifier = parseIdentifier(.summit) {
                
                return .summit(identifier)
                
            } else if let identifier = parseIdentifier(.member) {
                
                return .member(identifier)
                
            } else if let identifier = parseIdentifier(.event) {
                
                return .event(identifier)
                
            } else if let identifier = parseIdentifier(.team) {
                
                return .team(identifier)
                
            } else {
                
                return nil
            }
        }
        
        public init?(rawValue: String) {
            
            if let topic = Topic.parse(rawValue, with: "/topics/ios_") ?? Topic.parse(rawValue, with: "/topics/") {
                
                self = topic
                
            } else {
                
                return nil
            }
        }
        
        public var rawValue: String {
            
            var stringValue = "/topics/ios_" + Prefix(self).rawValue
            
            if let identifier = self.identifier {
                
                stringValue += "_\(identifier)"
            }
            
            return stringValue
        }
        
        public var hashValue: Int {
            
            return rawValue.hashValue
        }
    }
}
