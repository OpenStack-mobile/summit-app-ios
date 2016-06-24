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
        
    var pictureURL: String { get }
        
    //var email: String { get }
    
    var title: String? { get }
    
    var twitter: String? { get }
    
    var irc: String? { get }
    
    var biography: String? { get }
    
    //var location: String { get } // not sure?
}

public extension Person {
    
    var name: String { return firstName + " " + lastName }
}
