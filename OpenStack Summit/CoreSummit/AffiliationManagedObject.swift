//
//  AffiliationManagedObject.swift
//  OpenStack Summit
//
//  Created by Gabriel Horacio Cutrini on 3/24/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import CoreData
import SwiftFoundation

public final class AffiliationManagedObject: Entity {
    
    @NSManaged public var member: MemberManagedObject
    
    @NSManaged public var start: NSDate?
    
    @NSManaged public var end: NSDate?
    
    @NSManaged public var isCurrent: Bool
    
    @NSManaged public var organization: AffiliationOrganizationManagedObject
}

extension Affiliation: CoreDataDecodable {
    
    public init(managedObject: AffiliationManagedObject) {
        
        self.identifier = managedObject.identifier
        self.isCurrent = managedObject.isCurrent
        self.member =  managedObject.member.identifier
        self.organization = AffiliationOrganization(managedObject: managedObject.organization)
        
        if let startDate = managedObject.start {
            
            self.start = Date(foundation: startDate)
            
        } else {
            
            self.start = nil
        }
        
        if let endDate = managedObject.end {
            
            self.end = Date(foundation: endDate)
            
        } else {
            
            self.end = nil
        }
    }
}

extension Affiliation: CoreDataEncodable {
    
    public func save(context: NSManagedObjectContext) throws -> AffiliationManagedObject {
        
        let managedObject = try cached(context)

        managedObject.start = start?.toFoundation()
        managedObject.end = end?.toFoundation()
        managedObject.isCurrent = isCurrent
        managedObject.member = try context.relationshipFault(member)
        managedObject.organization = try context.relationshipFault(organization)
        
        managedObject.didCache()
        
        return managedObject
    }
}
