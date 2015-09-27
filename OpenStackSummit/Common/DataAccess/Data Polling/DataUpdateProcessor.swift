//
//  DataUpdateProcessor.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/24/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit

@objc
public protocol IDataUpdateProcessor {
    func process(data: String)
}

public class DataUpdateProcessor: NSObject {
    var dataUpdateDeserializer: DataUpdateDeserializer!
    var dataUpdateStrategyFactory: DataUpdateStrategyFactory!
    var dataUpdateDataStore: IDataUpdateDataStore!
    
    public init(dataUpdateDeserializer: DataUpdateDeserializer, dataUpdateStrategyFactory: DataUpdateStrategyFactory, dataUpdateDataStore: IDataUpdateDataStore) {
        self.dataUpdateDeserializer = dataUpdateDeserializer
        self.dataUpdateStrategyFactory = dataUpdateStrategyFactory
        self.dataUpdateDataStore = dataUpdateDataStore
    }
    
    public func process(data: String) {
        let dataUpdateArray = try! dataUpdateDeserializer.deserializeArray(data) as! [DataUpdate]
        var dataUpdateStrategy: IDataUpdateStrategy
        for dataUpdate in dataUpdateArray {
            dataUpdateStrategy = dataUpdateStrategyFactory.create(dataUpdate.entityClassName)
            dataUpdateStrategy.process(dataUpdate)
            dataUpdateDataStore.saveOrUpdateToLocal(dataUpdate, completionBlock: nil)
        }
    }
}
