//
//  PresentationSpeaker.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public struct Speaker: Person {
    
    public let identifier: Identifier
    
    public var firstName: String
    
    public var lastName: String
    
    public var title: String?
    
    public var pictureURL: String
            
    public var twitter: String?
    
    public var irc: String?
    
    public var biography: String?
}

// MARK: - Person

public extension Speaker {
    
    var linkedIn: String? { return nil }
}

// MARK: - Equatable

public func == (lhs: Speaker, rhs: Speaker) -> Bool {
    
    return lhs.identifier == rhs.identifier
        && lhs.firstName == rhs.firstName
        && lhs.lastName == rhs.lastName
        && lhs.title == rhs.title
        && lhs.pictureURL == rhs.pictureURL
        && lhs.twitter == rhs.twitter
        && lhs.irc == rhs.irc
        && lhs.biography == rhs.biography
}
