//
//  AboutAssembly.swift
//  OpenStackSummit
//
//  Created by Claudio on 4/7/16.
//  Copyright © 2016 OpenStack. All rights reserved.
//

import UIKit
import Typhoon

class AboutAssembly: TyphoonAssembly {
    var applicationAssembly: ApplicationAssembly!
    var dtoAssemblersAssembly: DTOAssemblersAssembly!
    var dataStoreAssembly: DataStoreAssembly!
    var securityManagerAssembly: SecurityManagerAssembly!
    var eventsAssembly: EventsAssembly!
    
    
    dynamic func aboutWireframe() -> AnyObject {
        return TyphoonDefinition.withClass(AboutWireframe.self) {
            (definition) in
            
            definition.injectProperty("navigationController", with: self.applicationAssembly.navigationController())
            definition.injectProperty("revealViewController", with: self.applicationAssembly.revealViewController())
            definition.injectProperty("aboutViewController", with: self.aboutViewController())
        }
    }
    
    dynamic func aboutPresenter() -> AnyObject {
        return TyphoonDefinition.withClass(AboutPresenter.self) {
            (definition) in
            
            definition.injectProperty("interactor", with: self.aboutInteractor())
            definition.injectProperty("viewController", with: self.aboutViewController())
            definition.injectProperty("wireframe", with: self.aboutWireframe())
        }
    }
    
    dynamic func aboutInteractor() -> AnyObject {
        
        return TyphoonDefinition.withClass(AboutInteractor.self) {
            (definition) in
            definition.injectProperty("summitDataStore", with: self.dataStoreAssembly.summitDataStore())
            definition.injectProperty("summitDTOAssembler", with: self.dtoAssemblersAssembly.summitDTOAssembler())
        }
    }
    
    dynamic func aboutViewController() -> AnyObject {
        return TyphoonDefinition.withFactory(self.applicationAssembly.mainStoryboard(), selector: "instantiateViewControllerWithIdentifier:", parameters: {
            (factoryMethod) in
            
            factoryMethod.injectParameterWith("AboutViewController")
            }, configuration: {
                (definition) in
                definition.injectProperty("presenter", with: self.aboutPresenter())
        })
    }
}