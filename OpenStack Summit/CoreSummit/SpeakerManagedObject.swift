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
}

// MARK: - Encoding

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
        self.affiliations = Affiliation.from(managedObjects: managedObject.affiliations)
    }
}

extension Speaker: CoreDataEncodable {
    
    public func save(context: NSManagedObjectContext) throws -> SpeakerManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.firstName = firstName
        managedObject.lastName = lastName
        managedObject.addressBookSectionName = addressBookSectionName
        managedObject.title = title
        managedObject.pictureURL = pictureURL
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
    
    public enum Property: String {
        
        case id, firstName, lastName, addressBookSectionName, title, pictureURL, twitter, irc, biography, member
    }
    
    static var sortDescriptors: [NSSortDescriptor] {
        
        return [NSSortDescriptor(key: Property.addressBookSectionName.rawValue, ascending: true),
                NSSortDescriptor(key: Property.firstName.rawValue, ascending: true),
                NSSortDescriptor(key: Property.lastName.rawValue, ascending: true),
                NSSortDescriptor(key: Property.id.rawValue, ascending: true)]
    }
}

public extension Speaker {
    
    static func filter(searchTerm: String = "",
                       page: Int, objectsPerPage: Int,
                       summit: Identifier? = nil,
                       context: NSManagedObjectContext) throws -> [Speaker] {
        
        var predicates = [NSPredicate]()
        
        if searchTerm.isEmpty == false {
            
            let searchPredicate = NSPredicate(format: "firstName CONTAINS[c] %@ OR lastName CONTAINS[c] %@", searchTerm, searchTerm)
            
            predicates.append(searchPredicate)
        }
        
        if let summitID = summit,
            let summit = try SummitManagedObject.find(summitID, context: context) {
            
            let summitPredicate = NSPredicate(format: "%@ IN summits", summit)
            
            predicates.append(summitPredicate)
        }
        
        let predicate: NSPredicate?
        
        if predicates.count > 1 {
            
            predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
            
        } else {
            
            predicate = predicates.first
        }
        
        let results = try context.managedObjects(ManagedObject.self, predicate: predicate, sortDescriptors: ManagedObject.sortDescriptors)
        
        var speakers = [ManagedObject]()
        
        let startRecord = (page - 1) * objectsPerPage
        
        let endRecord = (startRecord + (objectsPerPage - 1)) <= results.count ? startRecord + (objectsPerPage - 1) : results.count - 1
        
        if (startRecord <= endRecord) {
            
            for index in (startRecord...endRecord) {
                speakers.append(results[index])
            }
        }
        
        return Speaker.from(managedObjects: speakers)
    }
}
