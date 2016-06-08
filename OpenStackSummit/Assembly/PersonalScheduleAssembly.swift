//
//  PersonalScheduleAssembly.swift
//  OpenStackSummit
//
//  Created by Claudio on 10/19/15.
//  Copyright © 2015 OpenStack. All rights reserved.
//

import UIKit
import Typhoon

class PersonalScheduleAssembly: TyphoonAssembly {
    var applicationAssembly: ApplicationAssembly!
    var eventDetailAssembly: EventDetailAssembly!
    var dataStoreAssembly: DataStoreAssembly!
    var securityManagerAssembly: SecurityManagerAssembly!
    var dtoAssemblersAssembly: DTOAssemblersAssembly!
    var dataUpdateAssembly: DataUpdateAssembly!
    
    dynamic func personalScheduleWireframe() -> AnyObject {
        return TyphoonDefinition.withClass(PersonalScheduleWireframe.self) {
            (definition) in
            
            definition.injectProperty("personalScheduleViewController", with: self.personalScheduleViewController())
            definition.injectProperty("eventDetailWireframe", with: self.eventDetailAssembly.eventDetailWireframe())
        }
    }
    
    dynamic func personalScheduleInteractor() -> AnyObject {
        return TyphoonDefinition.withClass(PersonalScheduleInteractor.self) {
            (definition) in
            definition.injectProperty("summitDataStore", with: self.dataStoreAssembly.summitDataStore())
            definition.injectProperty("summitDTOAssembler", with: self.dtoAssemblersAssembly.summitDTOAssembler())
            definition.injectProperty("eventDataStore", with: self.dataStoreAssembly.eventDataStore())
            definition.injectProperty("scheduleItemDTOAssembler", with: self.dtoAssemblersAssembly.scheduleItemDTOAssembler())
            definition.injectProperty("summitAttendeeDataStore", with: self.dataStoreAssembly.summitAttendeeDataStore())
            definition.injectProperty("securityManager", with: self.securityManagerAssembly.securityManager())
            definition.injectProperty("dataUpdatePoller", with: self.dataUpdateAssembly.dataUpdatePoller())
            definition.injectProperty("pushNotificationsManager", with: self.applicationAssembly.pushNotificationsManager())
            definition.injectProperty("reachability", with: self.applicationAssembly.reachability())
        }
    }
    
    dynamic func personalSchedulePresenter() -> AnyObject {
        return TyphoonDefinition.withClass(PersonalSchedulePresenter.self) {
            (definition) in
            
            definition.injectProperty("viewController", with: self.personalScheduleViewController())
            definition.injectProperty("interactor", with: self.personalScheduleInteractor())
            definition.injectProperty("wireframe", with: self.personalScheduleWireframe())
            definition.injectProperty("session", with: self.applicationAssembly.session())
            definition.injectProperty("scheduleFilter", with: self.applicationAssembly.scheduleFilter())
        }
    }
    
    dynamic func personalScheduleViewController() -> AnyObject {
        return TyphoonDefinition.withFactory(self.applicationAssembly.mainStoryboard(), selector: "instantiateViewControllerWithIdentifier:", parameters: {
            (factoryMethod) in
            
            factoryMethod.injectParameterWith("PersonalScheduleViewController")
            }, configuration: {
                (definition) in
                
                definition.injectProperty("presenter", with: self.personalSchedulePresenter())
        })
    }
}
