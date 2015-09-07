//
//  RouterAssembly.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/4/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Typhoon

public class RouterAssembly: TyphoonAssembly {
    var applicationAssembly: ApplicationAssembly!
    var generalScheduleAssembly: GeneralScheduleAssembly!
    
    dynamic func router() -> AnyObject {
        return TyphoonDefinition.withClass(Router.self) {
            (definition) in
            
            definition.injectProperty("storyboard", with: self.applicationAssembly.mainStoryboard())
            definition.scope = TyphoonScope.Singleton
        }
    }
}
