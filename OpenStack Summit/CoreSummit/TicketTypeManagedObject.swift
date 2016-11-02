//
//  TicketTypeManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData

public final class TicketTypeManagedObject: Entity {
    
    
}

extension TicketType: CoreDataDecodable {
    
    public init(managedObject: TicketTypeManagedObject) {
        
        self.identifier = managedObject.identifier
        self.name = managedObject.name
        self.descriptionText = managedObject.descriptionText
        self.allowedSummitTypes = managedObject.allowedSummitTypes.identifiers
    }
}