//
//  BaseInteractorAssembly.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/8/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Typhoon

class BaseInteractorAssembly: TyphoonAssembly {
    
    dynamic func baseInteractor() -> AnyObject {
        return TyphoonDefinition.withClass(BaseInteractor.self) {
            (definition) in
            
            definition.injectProperty("session", with: self.baseInteractorSession())
        }
    }

    dynamic func baseInteractorSession() -> AnyObject {
        return TyphoonDefinition.withClass(Session.self)
    }
}
