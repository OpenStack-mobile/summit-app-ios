//
//  DataUpdateProcessGenericStrategy.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/25/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IDataUpdateStrategy {
    func process(dataUpdate: DataUpdate)
}

public class DataUpdateStrategy: NSObject, IDataUpdateStrategy {
    var genericDataStore: GenericDataStore!
    
    public func process(dataUpdate: DataUpdate) {
        switch dataUpdate.operation! {
        case .Insert, .Update:
            genericDataStore.saveOrUpdateToLocal(dataUpdate.entity, completionBlock: nil)
        case .Delete:
            genericDataStore.deleteFromLocal(dataUpdate.entity, completionBlock: nil)
        }
    }
}
