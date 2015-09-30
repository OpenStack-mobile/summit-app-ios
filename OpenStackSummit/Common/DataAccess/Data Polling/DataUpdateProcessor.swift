//
//  DataUpdateProcessor.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/24/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

public class DataUpdateProcessor: NSObject {
    var dataUpdateDeserializer: DataUpdateDeserializer!
    var dataUpdateStrategyFactory: DataUpdateStrategyFactory!
    var dataUpdateDataStore: IDataUpdateDataStore!
    
    public override init() {
        super.init()
    }
    
    public init(dataUpdateDeserializer: DataUpdateDeserializer, dataUpdateStrategyFactory: DataUpdateStrategyFactory, dataUpdateDataStore: IDataUpdateDataStore) {
        self.dataUpdateDeserializer = dataUpdateDeserializer
        self.dataUpdateStrategyFactory = dataUpdateStrategyFactory
        self.dataUpdateDataStore = dataUpdateDataStore
    }
    
    public func process(data: String) throws {
        let dataUpdateArray = try dataUpdateDeserializer.deserializeArray(data) as! [DataUpdate]
        var dataUpdateStrategy: DataUpdateStrategy
        for dataUpdate in dataUpdateArray {
            dataUpdateStrategy = dataUpdateStrategyFactory.create(dataUpdate.entityClassName)
            try dataUpdateStrategy.process(dataUpdate)
            dataUpdateDataStore.saveOrUpdateToLocal(dataUpdate, completionBlock: nil)
        }
    }
}
