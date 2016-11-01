//
//  ManagedObject.swift
//  OpenStack Summit
//
//  Created by Alsey Coleman Miller on 11/1/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import Foundation
import CoreData

/// Base CoreData Entity `NSManagedObject` subclass for CoreSummit.
public class Entity: NSManagedObject {
    
    @NSManaged var id: Int64
}

// MARK: - Extensions


