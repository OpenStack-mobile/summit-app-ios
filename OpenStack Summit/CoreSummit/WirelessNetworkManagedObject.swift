//
//  WirelessNetworkManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 2/6/17.
//  Copyright © 2017 OpenStack. All rights reserved.
//

import Foundation
import CoreData
import Foundation

public final class WirelessNetworkManagedObject: Entity {
    
    @NSManaged public var name: String
    
    @NSManaged public var password: String
    
    @NSManaged public var descriptionText: String?
    
    @NSManaged public var summit: SummitManagedObject
}

// MARK: - Encoding

extension WirelessNetwork: CoreDataDecodable {
    
    public init(managedObject: WirelessNetworkManagedObject) {
        
        self.identifier = managedObject.id
        self.name = managedObject.name
        self.password = managedObject.password
        self.descriptionText = managedObject.descriptionText
        self.summit = managedObject.summit.id
    }
}

extension WirelessNetwork: CoreDataEncodable {
    
    public func save(_ context: NSManagedObjectContext) throws -> WirelessNetworkManagedObject {
        
        let managedObject = try cached(context)
        
        managedObject.name = name
        managedObject.password = password
        managedObject.descriptionText = descriptionText
        managedObject.summit = try context.relationshipFault(summit)
        
        managedObject.didCache()
        
        return managedObject
    }
}

