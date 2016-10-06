//
//  PresentationSpeaker.swift
//  OpenStackSummit
//
//  Created by Alsey Coleman Miller on 6/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

public struct PresentationSpeaker: Person {
    
    public let identifier: Identifier
    
    public var firstName: String
    
    public var lastName: String
    
    public var title: String?
    
    public var pictureURL: String
            
    public var twitter: String?
    
    public var irc: String?
    
    public var biography: String?
    
    public var memberIdentifier: Identifier?
}
