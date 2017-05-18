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
    
    @NSManaged public var addressBookSectionName: String
    
    @NSManaged public var title: String?
    
    @NSManaged public var pictureURL: String
    
    @NSManaged public var twitter: String?
    
    @NSManaged public var irc: String?
    
    @NSManaged public var biography: String?
    
    @NSManaged public var affiliations: Set<AffiliationManagedObject>
    
    // Inverse Relationships
    
    @NSManaged public var summits: Set<SummitManagedObject>
    
    @NSManaged public var presentationModerator: Set<PresentationManagedObject>
    
    @NSManaged public var presentationSpeaker: Set<PresentationManagedObject>
}

// MARK: - Encoding

extension Speaker: CoreDataDecodable {
    
    public init(managedObject: SpeakerManagedObject) {
        
        self.identifier = managedObject.id
        self.firstName = managedObject.firstName
        self.lastName = managedObject.lastName
        self.title = managedObject.title
        self.picture = URL(string: managedObject.pictureURL)!
        self.twitter = managedObject.twitter
        self.irc = managedObject.irc
        self.biography = managedObject.biography
        self.affiliations = Affiliation.from(managedObjects: managedObject.affiliations)
    }
}

extension Speaker: CoreDataEncodable {
    
    public func save(_ context: NSManagedObjectContext) throws -> SpeakerManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.firstName = firstName
        managedObject.lastName = lastName
        managedObject.addressBookSectionName = AddressBook.section(for: self)
        managedObject.title = title
        managedObject.pictureURL = picture.absoluteString
        managedObject.twitter = twitter
        managedObject.irc = irc
        managedObject.biography = biography
        managedObject.affiliations = try context.relationshipFault(affiliations)
        
        managedObject.didCache()
        
        return managedObject
    }
}

// MARK: - Fetches

public extension SpeakerManagedObject {
    
    static var sortDescriptors: [NSSortDescriptor] {
        
        return [NSSortDescriptor(key: #keyPath(addressBookSectionName), ascending: true),
                NSSortDescriptor(key:#keyPath(SpeakerManagedObject.firstName), ascending: true),
                NSSortDescriptor(key:#keyPath(SpeakerManagedObject.lastName), ascending: true),
                NSSortDescriptor(key:#keyPath(SpeakerManagedObject.id), ascending: true)]
    }
}
