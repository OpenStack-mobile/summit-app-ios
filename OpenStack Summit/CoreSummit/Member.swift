//
//  Member.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public struct Member: Named {
    
    public let identifier: Identifier
    
    public let firstName: String
    
    public let lastName: String
    
    public let gender: String?
    
    public let pictureURL: String
        
    public let twitter: String?
    
    public let linkedIn: String?
    
    public let irc: String?
    
    public let biography: String?
        
    public let speakerRole: Speaker?
    
    public let attendeeRole: Attendee?
    
    public let groupEvents: Set<Identifier>
    
    public let favoriteEvents: Set<Identifier>
    
    public let groups: Set<Group>
    
    public let feedback: Set<Identifier>
    
    public let affiliations: Set<Affiliation>
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
        && lhs.favoriteEvents == rhs.favoriteEvents
        && lhs.affiliations == rhs.affiliations
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

