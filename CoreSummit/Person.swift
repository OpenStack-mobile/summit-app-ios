//
//  Person.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 5/31/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public protocol Person: Named {
    
    var firstName: String { get }
    
    var lastName: String { get }
    
    var title: String { get }
    
    var pictureURL: String { get }
        
    var email: String { get }
    
    var twitter: String { get }
    
    var irc: String { get }
    
    var biography: String { get }
}

public extension Person {
    
    var name: String { return firstName + " " + lastName }
}

public struct GenericPerson {
    
    public let identifier: Identifier
    
    public var firstName: String
    
    public var lastName: String
    
    public var title: String
    
    public var pictureURL: String
    
    public var email: String
    
    public var twitter: String
    
    public var irc: String
    
    public var biography: String
}
