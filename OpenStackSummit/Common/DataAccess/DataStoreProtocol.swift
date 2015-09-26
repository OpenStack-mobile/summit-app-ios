//
//  SummitDataStoreProtocol.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/19/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public protocol IDataStore {
    
    func get(id: Int, completionBlock : (BaseEntity?) -> Void)
    func saveOrUpdateToLocal(entity: BaseEntity, completionBlock : ((BaseEntity) -> Void)!)
    func delete(entity: BaseEntity, completionBlock : ((Void) -> Void)!)
}