//
//  Member.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public struct Member: Named {
    
    public let identifier: Identifier
    
    public var firstName: String
    
    public var lastName: String
    
    public var gender: Gender?
    
    public var pictureURL: String
        
    public var twitter: String?
    
    public var linkedIn: String?
    
    public var irc: String?
    
    public var biography: String?
        
    public var speakerRole: Speaker?
    
    public var attendeeRole: Attendee?
    
    public var groupEvents: Set<Identifier>
    
    public var groups: Set<Group>
}

// MARK: - Equatable

public func == (lhs: Member, rhs: Member) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.firstName == rhs.firstName
        && lhs.lastName == rhs.lastName
        && lhs.pictureURL == rhs.pictureURL
        && lhs.twitter == rhs.twitter
        && lhs.irc == rhs.irc
        && lhs.linkedIn == rhs.linkedIn
        && lhs.speakerRole == rhs.speakerRole
        && lhs.attendeeRole == rhs.attendeeRole
        && lhs.groups == rhs.groups
        && lhs.groupEvents == rhs.groupEvents
}

// MARK: - Extensions

extension Member: Person {
    
    public var title: String? { return speakerRole?.title }
}

#if os(iOS)
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
#endif

// MARK: - Supporting Types

public enum MemberRole {
    
    case anonymous, attendee, speaker, member
}

