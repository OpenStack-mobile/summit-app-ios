//
//  Member.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public struct Member: Named, Equatable {
    
    public let identifier: Identifier
    
    public var firstName: String
    
    public var lastName: String
    
    public var pictureURL: String
        
    public var twitter: String?
    
    public var irc: String?
    
    public var biography: String?
        
    public var speakerRole: Speaker?
    
    public var attendeeRole: Attendee?
}

// MARK: - Equatable

public func == (lhs: Member, rhs: Member) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.firstName == rhs.firstName
        && lhs.lastName == rhs.lastName
        && lhs.pictureURL == rhs.pictureURL
        && lhs.twitter == rhs.twitter
        && lhs.irc == rhs.irc
        && lhs.speakerRole == rhs.speakerRole
        && lhs.attendeeRole == rhs.attendeeRole
}

// MARK: - Extensions

extension Member: Person {
    
    public var title: String? { return nil }
}

public extension Store {
    
    var memberRole: MemberRole {
        
        guard isLoggedIn
            else { return .anonymous }
        
        if let currentMember = self.authenticatedMember {
            
            if (currentMember.speakerRole != nil) {
                
                return .speaker
            }
            else if (currentMember.attendeeRole != nil) {
                
                return .attendee
            }
            else {
                
                return .member
            }
        } else {
            
            return .member
        }
    }
}

// MARK: - Supporting Types

public extension Store {
    
    public enum MemberRole {
        
        case anonymous, attendee, speaker, member
    }
}

