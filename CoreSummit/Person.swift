//
//  Person.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 5/31/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public protocol PersonProtocol: Named {
    
    var lastName: String { get }
    
    var title: String { get }
    
    var pictureURL: String { get }
    
    var location: String { get }
    
    var email: String { get }
    
    var twitter: String { get }
    
    var irc: String { get }
    
    var biography: String { get }
}

public struct Person: Named {
    
    public let identifier: Identifier
    
    public var firstName: String
    
    public var lastName: String
    
    public var title: String
    
    public var pictureURL: String
    
    public var location: String
    
    public var email: String
    
    public var twitter: String
    
    public var irc: String
    
    public var biography: String
    
    // Not JSON
    
    public var name: String { return firstName + " " + lastName }
    
    public var type: PersonType = PersonType()
}

public enum PersonType {
    
    case generic, speaker, attendee
    
    public init() { self = .generic }
}
