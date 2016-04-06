//
//  MemberOrderConfirmAssembly.swift
//  OpenStackSummit
//
//  Created by Claudio on 4/4/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit
import Typhoon

class MemberOrderConfirmAssembly: TyphoonAssembly {
    var applicationAssembly: ApplicationAssembly!
    var dtoAssemblersAssembly: DTOAssemblersAssembly!
    var dataStoreAssembly: DataStoreAssembly!
    
    dynamic func memberOrderConfirmWireframe() -> AnyObject {
        return TyphoonDefinition.withClass(MemberOrderConfirmWireframe.self) {
            (definition) in
            
            definition.injectProperty("navigationController", with: self.applicationAssembly.navigationController())
            definition.injectProperty("revealViewController", with: self.applicationAssembly.revealViewController())
            definition.injectProperty("memberOrderConfirmViewController", with: self.memberOrderConfirmViewController())
        }
    }
    
    dynamic func memberOrderConfirmPresenter() -> AnyObject {
        return TyphoonDefinition.withClass(MemberOrderConfirmPresenter.self) {
            (definition) in
            
            definition.injectProperty("interactor", with: self.memberOrderConfirmInteractor())
            definition.injectProperty("viewController", with: self.memberOrderConfirmViewController())
            definition.injectProperty("wireframe", with: self.memberOrderConfirmWireframe())
        }
    }
    
    dynamic func memberOrderConfirmInteractor() -> AnyObject {
        
        return TyphoonDefinition.withClass(MemberOrderConfirmInteractor.self) {
            (definition) in
        }
    }
    
    dynamic func memberOrderConfirmViewController() -> AnyObject {
        return TyphoonDefinition.withFactory(self.applicationAssembly.mainStoryboard(), selector: "instantiateViewControllerWithIdentifier:", parameters: {
            (factoryMethod) in
            
            factoryMethod.injectParameterWith("MemberOrderConfirmViewController")
            }, configuration: {
                (definition) in
                definition.injectProperty("presenter", with: self.memberOrderConfirmPresenter())
        })
    }
}