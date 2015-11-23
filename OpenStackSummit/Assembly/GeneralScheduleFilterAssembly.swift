//
//  GeneralScheduleFilterAssembly.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/27/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Typhoon

public class GeneralScheduleFilterAssembly: TyphoonAssembly {
    var applicationAssembly: ApplicationAssembly!
    var dataStoreAssembly: DataStoreAssembly!
    var dtoAssemblersAssembly: DTOAssemblersAssembly!

    dynamic func generalScheduleFilterWireframe() -> AnyObject {
        return TyphoonDefinition.withClass(GeneralScheduleFilterWireframe.self) {
            (definition) in
            
            definition.injectProperty("generalScheduleFilterViewController", with: self.generalScheduleFilterViewController())
        }
    }
    
    dynamic func generalScheduleFilterPresenter() -> AnyObject {
        return TyphoonDefinition.withClass(GeneralScheduleFilterPresenter.self) {
            (definition) in
            
            definition.injectProperty("interactor", with: self.generalScheduleFilterInteractor())
            definition.injectProperty("scheduleFilter", with: self.applicationAssembly.scheduleFilter())
            definition.injectProperty("session", with: self.applicationAssembly.session())
            definition.injectProperty("viewController", with: self.generalScheduleFilterViewController())
        }
    }
    
    dynamic func generalScheduleFilterInteractor() -> AnyObject {
        return TyphoonDefinition.withClass(GeneralScheduleFilterInteractor.self) {
            (definition) in
            
            definition.injectProperty("summitTypeDataStore", with: self.dataStoreAssembly.summitTypeDataStore())
            definition.injectProperty("eventTypeDataStore", with: self.dataStoreAssembly.eventTypeDataStore())
            definition.injectProperty("trackDataStore", with: self.dataStoreAssembly.trackDataStore())
            definition.injectProperty("tagDataStore", with: self.dataStoreAssembly.tagDataStore())
            definition.injectProperty("namedDTOAssembler", with: self.dtoAssemblersAssembly.namedDTOAssembler())
        }
    }
        
    /*dynamic func generalScheduleFilterViewController() -> AnyObject {
        return TyphoonDefinition.withClass(GeneralScheduleFilterViewController.self) {
            (definition) in
            
            definition.injectProperty("presenter", with: self.generalScheduleFilterPresenter())
        }
    }*/
    
    dynamic func generalScheduleFilterViewController() -> AnyObject {
        return TyphoonDefinition.withFactory(self.applicationAssembly.mainStoryboard(), selector: "instantiateViewControllerWithIdentifier:", parameters: {
            (factoryMethod) in
            
            factoryMethod.injectParameterWith("GeneralScheduleFilterViewController")
            }, configuration: {
                (definition) in
                definition.injectProperty("presenter", with: self.generalScheduleFilterPresenter())
        })
    }

}
