//
//  SpeakerManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData

public final class SpeakerManagedObject: Entity {
    
    @NSManaged public var firstName: String
    
    @NSManaged public var lastName: String
    
    @NSManaged public var title: String?
    
    @NSManaged public var pictureURL: String
    
    @NSManaged public var twitter: String?
    
    @NSManaged public var irc: String?
    
    @NSManaged public var biography: String?
    
    @NSManaged public var member: NSNumber?
}

extension Speaker: CoreDataDecodable {
    
    public init(managedObject: SpeakerManagedObject) {
        
        self.identifier = managedObject.identifier
        self.firstName = managedObject.firstName
        self.lastName = managedObject.lastName
        self.title = managedObject.title
        self.pictureURL = managedObject.pictureURL
        self.twitter = managedObject.twitter
        self.irc = managedObject.irc
        self.biography = managedObject.biography
        self.memberIdentifier = managedObject.member?.integerValue
    }
}

extension Speaker: CoreDataEncodable {
    
    public func save(context: NSManagedObjectContext) throws -> SpeakerManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.firstName = firstName
        managedObject.lastName = lastName
        managedObject.title = title
        managedObject.pictureURL = pictureURL
        managedObject.twitter = twitter
        managedObject.irc = irc
        managedObject.biography = biography
        managedObject.member = memberIdentifier
        
        managedObject.didCache()
        
        return managedObject
    }
}