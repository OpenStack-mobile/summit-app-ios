//
//  LevelScheduleAssembly.swift
//  OpenStackSummit
//
//  Created by Claudio on 12/9/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Typhoon

class LevelScheduleAssembly: TyphoonAssembly {
    var applicationAssembly: ApplicationAssembly!
    var eventDetailAssembly: EventDetailAssembly!
    var dataStoreAssembly: DataStoreAssembly!
    var securityManagerAssembly: SecurityManagerAssembly!
    var dtoAssemblersAssembly: DTOAssemblersAssembly!
    var dataUpdateAssembly: DataUpdateAssembly!
    
    dynamic func levelScheduleWireframe() -> AnyObject {
        return TyphoonDefinition.withClass(LevelScheduleWireframe.self) {
            (definition) in
            
            definition.injectProperty("LevelScheduleViewController", with: self.levelScheduleViewController())
            definition.injectProperty("eventDetailWireframe", with: self.eventDetailAssembly.eventDetailWireframe())
        }
    }
    
    dynamic func levelScheduleInteractor() -> AnyObject {
        return TyphoonDefinition.withClass(LevelScheduleInteractor.self) {
            (definition) in
            definition.injectProperty("summitDataStore", with: self.dataStoreAssembly.summitDataStore())
            definition.injectProperty("summitDTOAssembler", with: self.dtoAssemblersAssembly.summitDTOAssembler())
            definition.injectProperty("eventDataStore", with: self.dataStoreAssembly.eventDataStore())
            definition.injectProperty("scheduleItemDTOAssembler", with: self.dtoAssemblersAssembly.scheduleItemDTOAssembler())
            definition.injectProperty("summitAttendeeDataStore", with: self.dataStoreAssembly.summitAttendeeDataStore())
            definition.injectProperty("securityManager", with: self.securityManagerAssembly.securityManager())
            definition.injectProperty("dataUpdatePoller", with: self.dataUpdateAssembly.dataUpdatePoller())
            definition.injectProperty("pushNotificationsManager", with: self.applicationAssembly.pushNotificationsManager())
        }
    }
    
    dynamic func levelSchedulePresenter() -> AnyObject {
        return TyphoonDefinition.withClass(LevelSchedulePresenter.self) {
            (definition) in
            
            definition.injectProperty("viewController", with: self.levelScheduleViewController())
            definition.injectProperty("interactor", with: self.levelScheduleInteractor())
            definition.injectProperty("wireframe", with: self.levelScheduleWireframe())
            definition.injectProperty("session", with: self.applicationAssembly.session())
            definition.injectProperty("scheduleFilter", with: self.applicationAssembly.scheduleFilter())
        }
    }
    
    dynamic func levelScheduleViewController() -> AnyObject {
        return TyphoonDefinition.withFactory(self.applicationAssembly.mainStoryboard(), selector: "instantiateViewControllerWithIdentifier:", parameters: {
            (factoryMethod) in
            
            factoryMethod.injectParameterWith("LevelScheduleViewController")
            }, configuration: {
                (definition) in
                definition.injectProperty("presenter", with: self.levelSchedulePresenter())
        })
    }
}

