//
//  Member.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public struct Member: Person {
    
    public let identifier: Identifier
    
    public var firstName: String
    
    public var lastName: String
    
    public var title: String?
    
    public var pictureURL: String
    
    public var email: String
    
    public var twitter: String?
    
    public var irc: String?
    
    public var biography: String?
    
    //public var friends: [Identifier] // not in JSON
    
    public var speakerRole: PresentationSpeaker?
    
    public var attendeeRole: SummitAttendee?
}

// MARK: - Supporting Types

public extension Member {
    
    public enum Role {
        
        case Anonymous, Attendee, Speaker, Member
    }
}

