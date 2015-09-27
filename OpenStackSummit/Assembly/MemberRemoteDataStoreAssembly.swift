//
//  MemberRemoteDataStorageAssembly.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/3/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Typhoon

public class MemberRemoteDataStoreAssembly: TyphoonAssembly {
    var dataStoreAssembly : DataStoreAssembly!
    var httpFactoryAssembly: HttpFactoryAssembly!
    
    public dynamic func memberRemoteDataStore() -> AnyObject {
        
        return TyphoonDefinition.withClass(MemberRemoteDataStore.self) {
            (definition) in
             definition.injectProperty("deserializerFactory", with: self.dataStoreAssembly.deserializerFactory())
             definition.injectProperty("httpFactory", with: self.httpFactoryAssembly.httpFactory())
        }
    }    
}
