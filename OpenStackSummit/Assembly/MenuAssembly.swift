//
//  MenuAssembly.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/24/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Typhoon

public class MenuAssembly: TyphoonAssembly {
    var applicationAssembly: ApplicationAssembly!
    var memberProfileAssembly: MemberProfileAssembly!
    var dtoAssemblersAssembly: DTOAssemblersAssembly!
    var securityManagerAssembly: SecurityManagerAssembly!
    
    dynamic func menuWireframe() -> AnyObject {
        return TyphoonDefinition.withClass(MenuWireframe.self) {
            (definition) in
            
            definition.injectProperty("menuViewController", with: self.menuViewController())
            definition.injectProperty("memberProfileWireframe", with: self.memberProfileAssembly.memberProfileWireframe())
        }
    }
    
    dynamic func menuPresenter() -> AnyObject {
        return TyphoonDefinition.withClass(MenuPresenter.self) {
  
            (definition) in
            
            definition.injectProperty("interactor", with: self.menuInteractor())
            definition.injectProperty("wireframe", with: self.menuWireframe())
            definition.injectProperty("viewController", with: self.menuViewController())
            definition.injectProperty("securityManager", with: self.securityManagerAssembly.securityManager())
        }
    }
    
    dynamic func menuInteractor() -> AnyObject {
        return TyphoonDefinition.withClass(MenuInteractor.self) {
            (definition) in
            
            definition.injectProperty("session", with: self.applicationAssembly.session())
            definition.injectProperty("securityManager", with: self.securityManagerAssembly.securityManager())
            definition.injectProperty("memberDTOAssembler", with: self.dtoAssemblersAssembly.memberDTOAssembler())
            definition.injectProperty("pushNotificationsManager", with: self.applicationAssembly.pushNotificationsManager())
        }
    }
    
    dynamic func menuViewController() -> AnyObject {
        return TyphoonDefinition.withClass(MenuViewController.self) {
            (definition) in
            
            definition.injectProperty("presenter", with: self.menuPresenter())
            definition.injectProperty("session", with: self.applicationAssembly.session())
        }
    }
}
