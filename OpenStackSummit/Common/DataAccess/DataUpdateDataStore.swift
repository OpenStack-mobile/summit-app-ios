//
//  DataUpdateStore.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/26/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public protocol IDataUpdateDataStore {
    func getGeneralUpdatesAfterIdFromOrigin(id: Int, completionBlock : ([DataUpdate]?, NSError?) -> Void)
    func saveOrUpdateToLocal(entity: DataUpdate, completionBlock: ((DataUpdate?, NSError?) -> Void)?)
    func getLatestDataUpdate() -> DataUpdate?
}

public class DataUpdateDataStore: GenericDataStore, IDataUpdateDataStore {
    var dataUpdateRemoteDataStore: IDataUpdateRemoteDataStore!
    
    public override init() {
        super.init()
    }
    
    public func getGeneralUpdatesAfterIdFromOrigin(id: Int, completionBlock : ([DataUpdate]?, NSError?) -> Void) {
        dataUpdateRemoteDataStore.getGeneralUpdatesAfterId(id, completionBlock: completionBlock)
    }
    
    public func saveOrUpdateToLocal(entity: DataUpdate, completionBlock: ((DataUpdate?, NSError?) -> Void)?) {
        super.saveOrUpdateToLocal(entity, completionBlock: completionBlock)
    }
    
    public func getLatestDataUpdate() -> DataUpdate? {
        return realm.objects(DataUpdate).filter("@max.id").first
    }
}
