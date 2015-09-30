//
//  DataUpdateProcessGenericStrategy.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/25/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public class DataUpdateStrategy: NSObject {
    var genericDataStore: GenericDataStore!
    
    public override init() {
        super.init()
    }
    
    public init(genericDataStore: GenericDataStore) {
        self.genericDataStore = genericDataStore
    }
    
    public func process(dataUpdate: DataUpdate) throws {
        switch dataUpdate.operation! {
        case .Insert, .Update:
            genericDataStore.saveOrUpdateToLocal(dataUpdate.entity, completionBlock: nil)
        case .Delete:
            genericDataStore.deleteFromLocal(dataUpdate.entity, completionBlock: nil)
        }
    }
}
