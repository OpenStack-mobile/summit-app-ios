//
//  SummitDataStoreProtocol.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/19/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public protocol IDataStore {
    
    func get(id: Int, completitionBlock : (BaseEntity?) -> Void)
    func saveOrUpdate(entity: BaseEntity, completitionBlock : ((BaseEntity) -> Void)!)
    func delete(entity: BaseEntity, completitionBlock : ((Void) -> Void)!)
}