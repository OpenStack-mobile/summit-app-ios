//
//  AffiliationManagedObject.swift
//  OpenStack Summit
//
//  Created by Gabriel Horacio Cutrini on 3/24/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import CoreData
import Foundation

public final class AffiliationManagedObject: Entity {
    
    @NSManaged public var member: MemberManagedObject
    
    @NSManaged public var start: Date?
    
    @NSManaged public var end: Date?
    
    @NSManaged public var isCurrent: Bool
    
    @NSManaged public var organization: AffiliationOrganizationManagedObject
}

extension Affiliation: CoreDataDecodable {
    
    public init(managedObject: AffiliationManagedObject) {
        
        self.identifier = managedObject.id
        self.isCurrent = managedObject.isCurrent
        self.member =  managedObject.member.id
        self.organization = AffiliationOrganization(managedObject: managedObject.organization)
        
        if let startDate = managedObject.start {
            
            self.start = startDate
            
        } else {
            
            self.start = nil
        }
        
        if let endDate = managedObject.end {
            
            self.end = endDate
            
        } else {
            
            self.end = nil
        }
    }
}

extension Affiliation: CoreDataEncodable {
    
    public func save(_ context: NSManagedObjectContext) throws -> AffiliationManagedObject {
        
        let managedObject = try cached(context)

        managedObject.start = start
        managedObject.end = end
        managedObject.isCurrent = isCurrent
        managedObject.member = try context.relationshipFault(member)
        managedObject.organization = try context.relationshipFault(organization)
        
        managedObject.didCache()
        
        return managedObject
    }
}
