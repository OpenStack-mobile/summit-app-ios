//
//  MemberManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData

public final class MemberManagedObject: Entity {
    
    @NSManaged public var firstName: String
    
    @NSManaged public var lastName: String
    
    @NSManaged public var pictureURL: String
    
    @NSManaged public var twitter: String?
    
    @NSManaged public var irc: String?
    
    @NSManaged public var biography: String?
    
    @NSManaged public var speakerRole: SpeakerManagedObject?
    
    @NSManaged public var attendeeRole: AttendeeManagedObject?
}

extension Member: CoreDataDecodable {
    
    public init(managedObject: MemberManagedObject) {
        
        self.identifier = managedObject.identifier
    }
}

extension Member: CoreDataEncodable {
    
    public func save(context: NSManagedObjectContext) throws -> MemberManagedObject {
        
        
    }
}