//
//  SummitDataStoreProtocol.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/19/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public protocol DataStoreProtocol {
    typealias EntityType
    
    func get(id: Int, completitionBlock : (EntityType) -> Void)
    func saveOrUpdate(entity: EntityType, completitionBlock : (EntityType) -> Void)
    func delete(entity: EntityType, completitionBlock : () -> Void)
}
