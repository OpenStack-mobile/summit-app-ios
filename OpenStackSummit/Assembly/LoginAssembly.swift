//
//  LoginAssembly.swift
//  OpenStackSummit
//
//  Created by Claudio on 9/8/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Typhoon

public class LoginAssembly: TyphoonAssembly {
    var applicationAssembly: ApplicationAssembly!
    
    dynamic func loginWireframe() -> AnyObject {
        return TyphoonDefinition.withClass(LoginWireframe.self) {
            (definition) in
            
            definition.injectProperty("loginViewController", with: self.loginViewController())
        }
    }
    
    dynamic func loginPresenter() -> AnyObject {
        return TyphoonDefinition.withClass(LoginPresenter.self) {
            (definition) in
            
            definition.injectProperty("interactor", with: self.loginInteractor())
            definition.injectProperty("viewController", with: self.loginViewController())
            definition.injectProperty("loginWireframe", with: self.loginWireframe())
        }
    }
    
    dynamic func loginInteractor() -> AnyObject {
        return TyphoonDefinition.withClass(LoginInteractor.self) {
            (definition) in
            
            definition.injectProperty("session", with: self.loginInteractorSession())
            definition.injectProperty("securityManager", with: self.loginInteractorSecurityManager())

        }
    }
    
    dynamic func loginInteractorSecurityManager() -> AnyObject {
        return TyphoonDefinition.withClass(SecurityManager.self) {
            (definition) in
            
            definition.scope = TyphoonScope.Singleton
        }
    }

    dynamic func loginInteractorSession() -> AnyObject {
        return TyphoonDefinition.withClass(Session.self)
    }
    
    dynamic func loginViewController() -> AnyObject {
        return TyphoonDefinition.withClass(LoginViewController.self) {
            (definition) in
            
            definition.injectProperty("presenter", with: self.loginPresenter())
        }
    }
}
