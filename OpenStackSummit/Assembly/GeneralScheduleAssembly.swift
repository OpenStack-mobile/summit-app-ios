//
//  GeneralScheduleAssembly.swift
//  OpenStackSummit
//
//  Created by Claudio on 8/7/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Typhoon

class GeneralScheduleAssembly: TyphoonAssembly {
    var applicationAssembly: ApplicationAssembly!
    var eventDetailAssembly: EventDetailAssembly!
    var dataStoreAssembly: DataStoreAssembly!
    var securityManagerAssembly: SecurityManagerAssembly!
    var dtoAssemblersAssembly: DTOAssemblersAssembly!
    
    dynamic func generalScheduleWireframe() -> AnyObject {
        return TyphoonDefinition.withClass(GeneralScheduleWireframe.self) {
            (definition) in
            
            definition.injectProperty("generalScheduleViewController", with: self.generalScheduleViewController())
            definition.injectProperty("eventDetailWireframe", with: self.eventDetailAssembly.eventDetailWireframe())
        }
    }
    
    dynamic func generalSchedulePresenter() -> AnyObject {
        return TyphoonDefinition.withClass(GeneralSchedulePresenter.self) {
            (definition) in
            
            definition.injectProperty("viewController", with: self.generalScheduleViewController())
            definition.injectProperty("interactor", with: self.generalScheduleInteractor())
            definition.injectProperty("wireframe", with: self.generalScheduleWireframe())
            definition.injectProperty("session", with: self.applicationAssembly.session())
            definition.injectProperty("scheduleFilter", with: self.applicationAssembly.scheduleFilter())
        }
    }
    
    dynamic func generalScheduleInteractor() -> AnyObject {
        return TyphoonDefinition.withClass(GeneralScheduleInteractor.self) {
            (definition) in
            
            definition.injectProperty("summitDataStore", with: self.dataStoreAssembly.summitDataStore())
            definition.injectProperty("summitDTOAssembler", with: self.dtoAssemblersAssembly.summitDTOAssembler())
            definition.injectProperty("eventDataStore", with: self.dataStoreAssembly.eventDataStore())
            definition.injectProperty("scheduleItemDTOAssembler", with: self.dtoAssemblersAssembly.scheduleItemDTOAssembler())
            definition.injectProperty("summitAttendeeDataStore", with: self.dataStoreAssembly.summitAttendeeDataStore())
            definition.injectProperty("securityManager", with: self.securityManagerAssembly.securityManager())
        }
    }
        
    dynamic func generalScheduleViewController() -> AnyObject {
        return TyphoonDefinition.withClass(GeneralScheduleViewController.self) {
            (definition) in
            
            definition.injectProperty("presenter", with: self.generalSchedulePresenter())
        }
    }    
}