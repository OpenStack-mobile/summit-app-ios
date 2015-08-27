//
//  DatabaseInitProcessAssembly.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/18/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Typhoon

public class SummitDataStoreAssembly: TyphoonAssembly {

    var dataStoreAssembly : DataStoreAssembly!
    
    public dynamic func summitDataStore() -> AnyObject {

        return TyphoonDefinition.withClass(SummitDataStore.self) {
            (definition) in
            definition.injectProperty("deserializerFactory", with: self.dataStoreAssembly.deserializerFactory())
            definition.injectProperty("trigger", with: SummitTrigger())
        }
    }
}
