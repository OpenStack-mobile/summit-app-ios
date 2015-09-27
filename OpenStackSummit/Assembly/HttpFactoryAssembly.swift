//
//  HttpFactoryAssembly.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/26/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Typhoon

public class HttpFactoryAssembly: TyphoonAssembly {
    var securityManagerAssembly: SecurityManagerAssembly!
    
    public dynamic func httpFactory() -> AnyObject {
        
        return TyphoonDefinition.withClass(HttpFactory.self) {
            (definition) in
            definition.injectProperty("securityManager", with: self.securityManagerAssembly.securityManager())
        }
    }

}
