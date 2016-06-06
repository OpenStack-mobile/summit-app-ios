//
//  SummitDataStoreProtocol.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/19/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import CoreSummit

public protocol DataStoreProtocol {
    
    func get(id: Int, completionBlock : (RealmEntity?) -> Void)
    func saveOrUpdateLocal(entity: RealmEntity, completionBlock : ((RealmEntity) -> Void)!)
    func delete(entity: RealmEntity, completionBlock : ((Void) -> Void)!)
}