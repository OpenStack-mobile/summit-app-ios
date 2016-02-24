//
//  LevelListAssembly.swift
//  OpenStackSummit
//
//  Created by Claudio on 12/9/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Typhoon

class LevelListAssembly: TyphoonAssembly {
    var applicationAssembly: ApplicationAssembly!
    var dataStoreAssembly: DataStoreAssembly!
    var dtoAssemblersAsembly: DTOAssemblersAssembly!
    var levelScheduleAssembly: LevelScheduleAssembly!
    
    dynamic func levelListWireframe() -> AnyObject {
        return TyphoonDefinition.withClass(LevelListWireframe.self) {
            (definition) in
            
            definition.injectProperty("levelScheduleWireframe", with: self.levelScheduleAssembly.levelScheduleWireframe())
            definition.injectProperty("levelListViewController", with: self.levelListViewController())
        }
    }
    
    dynamic func levelListPresenter() -> AnyObject {
        return TyphoonDefinition.withClass(LevelListPresenter.self) {
            (definition) in
            
            definition.injectProperty("viewController", with: self.levelListViewController())
            definition.injectProperty("interactor", with: self.levelListInteractor())
            definition.injectProperty("wireframe", with: self.levelListWireframe())
            definition.injectProperty("scheduleFilter", with: self.applicationAssembly.scheduleFilter())
        }
    }
    
    dynamic func levelListInteractor() -> AnyObject {
        return TyphoonDefinition.withClass(LevelListInteractor.self) {
            (definition) in

            definition.injectProperty("eventDataStore", with: self.dataStoreAssembly.eventDataStore())
        }
    }
    
    dynamic func levelListViewController() -> AnyObject {
        return TyphoonDefinition.withFactory(self.applicationAssembly.mainStoryboard(), selector: "instantiateViewControllerWithIdentifier:", parameters: {
            (factoryMethod) in
            
            factoryMethod.injectParameterWith("LevelListViewController")
            }, configuration: {
                (definition) in
                
                definition.injectProperty("presenter", with: self.levelListPresenter())
        })
    }
}
