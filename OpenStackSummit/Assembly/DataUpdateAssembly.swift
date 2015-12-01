//
//  DataUpdateAssembly.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/30/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Typhoon

public class DataUpdateAssembly: TyphoonAssembly {
    var httpFactoryAssembly: HttpFactoryAssembly!
    var dataStoreAssembly: DataStoreAssembly!
    var securityManagerAssembly: SecurityManagerAssembly!
    
    public dynamic func dataUpdatePoller() -> AnyObject {
        
        return TyphoonDefinition.withClass(DataUpdatePoller.self) {
            (definition) in
            definition.injectProperty("httpFactory", with: self.httpFactoryAssembly.httpFactory())
            definition.injectProperty("dataUpdateProcessor", with: self.dataUpdateProcessor())
            definition.injectProperty("dataUpdateDataStore", with: self.dataUpdateDataStore())
            definition.injectProperty("summitDataStore", with: self.dataStoreAssembly.summitDataStore())
        }
    }
    
    public dynamic func dataUpdateDataStore() -> AnyObject {
        
        return TyphoonDefinition.withClass(DataUpdateDataStore.self) {
            (definition) in
            
            definition.injectProperty("dataUpdateRemoteDataStore", with: self.dataUpdateRemoteDataStore())
        }
    }

    public dynamic func dataUpdateRemoteDataStore() -> AnyObject {
        
        return TyphoonDefinition.withClass(DataUpdateRemoteDataStore.self) {
            (definition) in
            definition.injectProperty("httpFactory", with: self.httpFactoryAssembly.httpFactory())
            definition.injectProperty("deserializerFactory", with: self.dataStoreAssembly.deserializerFactory())
        }
    }
    
    public dynamic func dataUpdateProcessor() -> AnyObject {
        
        return TyphoonDefinition.withClass(DataUpdateProcessor.self) {
            (definition) in
            definition.injectProperty("dataUpdateDeserializer", with: self.dataStoreAssembly.dataUpdateDeserializer())
            definition.injectProperty("dataUpdateStrategyFactory", with: self.dataUpdateStrategyFactory())
            definition.injectProperty("dataUpdateDataStore", with: self.dataUpdateDataStore())
        }
    }

    public dynamic func dataUpdateStrategyFactory() -> AnyObject {
        
        return TyphoonDefinition.withClass(DataUpdateStrategyFactory.self) {
            (definition) in
            
            definition.injectProperty("genericDataUpdateProcessStrategy", with: self.genericDataUpdateProcessStrategy())
            definition.injectProperty("myScheduleDataUpdateStrategy", with: self.myScheduleDataUpdateStrategy())
        }
    }

    public dynamic func genericDataUpdateProcessStrategy() -> AnyObject {
        
        return TyphoonDefinition.withClass(DataUpdateStrategy.self) {
            (definition) in
            
            definition.injectProperty("genericDataStore", with: self.dataStoreAssembly.genericDataStore())
        }
    }
    
    public dynamic func myScheduleDataUpdateStrategy() -> AnyObject {
        
        return TyphoonDefinition.withClass(MyScheduleDataUpdateStrategy.self) {
            (definition) in
            
            definition.injectProperty("summitAttendeeDataStore", with: self.dataStoreAssembly.summitAttendeeDataStore())
            definition.injectProperty("securityManager", with: self.securityManagerAssembly.securityManager())
        }
    }
    
}
