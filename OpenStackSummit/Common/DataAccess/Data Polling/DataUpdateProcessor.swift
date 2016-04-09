//
//  DataUpdateProcessor.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/24/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Crashlytics

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
            if dataUpdate.entity != nil {
                dataUpdateStrategy = dataUpdateStrategyFactory.create(dataUpdate.entityClassName)
                do {
                    try dataUpdateStrategy.process(dataUpdate)                    
                }
                catch {
                    let nsError = error as NSError
                    Crashlytics.sharedInstance().recordError(nsError)
                    printerr(nsError.localizedDescription)
                }
            }
            dataUpdateDataStore.saveOrUpdateLocal(dataUpdate, completionBlock: nil)
        }
    }
}
