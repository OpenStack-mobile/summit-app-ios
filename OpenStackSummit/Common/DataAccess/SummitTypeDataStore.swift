//
//  SummitTypeDataStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/27/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import CoreSummit

public protocol SummitTypeDataStoreProtocol {
    
    func getAllLocal() -> [RealmSummitType]
    
    func getByIdLocal(id: Int) -> RealmSummitType?
}

public class SummitTypeDataStore: GenericDataStore, SummitTypeDataStoreProtocol {
    
    public func getAllLocal() -> [RealmSummitType] {
        return super.getAllLocal()
    }
    
    public func getByIdLocal(id: Int) -> RealmSummitType? {
        return super.getByIdLocal(id)
    }
}

