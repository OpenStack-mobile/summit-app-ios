//
//  AttendeeManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/2/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData

public final class AttendeeManagedObject: Entity {
    
    @NSManaged public var firstName: String
    
    @NSManaged public var lastName: String
    
    @NSManaged public var pictureURL: String
    
    @NSManaged public var twitter: String?
    
    @NSManaged public var irc: String?
    
    @NSManaged public var biography: String?
    
    @NSManaged public var tickets: Set<TicketType>
    
    @NSManaged public var scheduledEvents: Set<EventManagedObject>
    
    @NSManaged public var feedback: Set<AttendeeFeedbackManagedObject>
}

extension Attendee: CoreDataDecodable {
    
    
}

extension Attendee: CoreDataEncodable {
    
    
}
