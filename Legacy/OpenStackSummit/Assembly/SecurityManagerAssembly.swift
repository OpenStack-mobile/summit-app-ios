//
//  SecurityManagerAssembly.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/17/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Typhoon

public class SecurityManagerAssembly: TyphoonAssembly {
    var dataStoreAssembly: DataStoreAssembly!
    
    public dynamic func securityManager() -> AnyObject {
        
        return TyphoonDefinition.withClass(SecurityManager.self) {
            (definition) in
            
            definition.injectProperty("session", with: self.securityManagerSession())
            definition.injectProperty("memberDataStore", with: self.dataStoreAssembly.memberDataStore())
            definition.scope = TyphoonScope.Singleton
        }
    }
    
    public dynamic func securityManagerSession() -> AnyObject {
        
        return TyphoonDefinition.withClass(Session.self)
    }
}
