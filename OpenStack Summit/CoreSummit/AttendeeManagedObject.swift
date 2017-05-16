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
    
    @NSManaged public var member: MemberManagedObject
    
    @NSManaged public var schedule: Set<EventManagedObject>
    
    @NSManaged public var tickets: Set<TicketTypeManagedObject>
}

extension Attendee: CoreDataDecodable {
    
    public init(managedObject: AttendeeManagedObject) {
        
        self.identifier = managedObject.id
        self.member = managedObject.member.id
        self.tickets = managedObject.tickets.identifiers
        self.schedule = managedObject.schedule.identifiers
    }
}

extension Attendee: CoreDataEncodable {
    
    public func save(_ context: NSManagedObjectContext) throws -> AttendeeManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.member = try context.relationshipFault(member)
        managedObject.tickets = try context.relationshipFault(tickets)
        managedObject.schedule = try context.relationshipFault(schedule)
        
        managedObject.didCache()
        
        return managedObject
    }
}
