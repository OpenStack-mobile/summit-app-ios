//
//  Notification.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 1/27/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import SwiftFoundation

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
        
        public init?(rawValue: String) {
            
            struct Cache {
                static var prefixRegularExpressions = [Prefix: NSRegularExpression]()
            }
            
            func parseIdentifier(prefix: Prefix) -> Identifier? {
                
                let prefixString = "/topics/" + prefix.rawValue + "_"
                
                guard rawValue.containsString(prefixString) else { return nil }
                
                // get regex
                
                let regularExpression: NSRegularExpression
                
                if let cached = Cache.prefixRegularExpressions[prefix] {
                    
                    regularExpression = cached
                    
                } else {
                    
                    regularExpression = try! NSRegularExpression(pattern: prefixString + "(\\d+)", options: [])
                    
                    Cache.prefixRegularExpressions[prefix] = regularExpression
                }
                
                // run regex
                
                guard let match = regularExpression.firstMatchInString(rawValue, options: [], range: NSMakeRange(0, (rawValue as NSString).length))
                    where match.numberOfRanges == 2
                    else { return nil }
                
                let matchString = (rawValue as NSString).substringWithRange(match.range)
                
                guard matchString == rawValue
                    else { return nil }
                
                let captureGroup = (rawValue as NSString).substringWithRange(match.rangeAtIndex(1))
                
                guard let identifier = Int(captureGroup)
                    else { return nil }
                
                return identifier
            }
            
            func parseCollection() -> Topic? {
                
                let prefixString = rawValue.stringByReplacingOccurrencesOfString("/topics/", withString: "")
                
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
                
                self = collectionTopic
                
            } else if let identifier = parseIdentifier(.summit) {
                
                self = .summit(identifier)
                
            } else if let identifier = parseIdentifier(.member) {
                
                self = .member(identifier)
                
            } else if let identifier = parseIdentifier(.event) {
                
                self = .event(identifier)
                
            } else if let identifier = parseIdentifier(.team) {
                
                self = .team(identifier)
                
            } else {
                
                return nil
            }
        }
        
        public var rawValue: String {
            
            var stringValue = "/topics/" + Prefix(self).rawValue
            
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
